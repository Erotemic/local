#!/usr/bin/env python3
"""Configure a provisioned AIVM Pi guest against the host's infer-stack gateway.

Requires Python 3.10+, and the host's installed aivm/infer-stack CLIs.
The AIVM mutation runs under the Python interpreter that installed aivm;
this script itself uses only the standard library.
"""

from __future__ import annotations

import argparse
import copy
import ipaddress
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


PACKAGE = 'npm:pi-provider-litellm'
DEFAULT_PREFERENCES = {
    'theme': 'dark',
    'compaction': {'enabled': True},
    'retry': {
        'enabled': True,
        'maxRetries': 5,
        'baseDelayMs': 2000,
        'maxAgentDelayMs': 60000,
        'provider': {
            'timeoutMs': 900000,
            'maxRetries': 0,
            'maxRetryDelayMs': 60000,
        },
    },
}
# Only copy known UI/agent preferences, never another host's credentials,
# model selection, provider routing, or third-party extension packages.
COPYABLE_KEYS = (
    'theme', 'compaction', 'retry', 'thinkingLevel', 'defaultThinkingLevel',
    'quietStartup', 'editor', 'shellPath', 'shellCommandPrefix',
    'steeringMode', 'followUpMode',
)
MARKER = 'PI_VM_SETUP_JSON:'

AIVM_BRIDGE = r'''
import json
import sys
from pathlib import Path

from aivm.services import load_vm_context_with_path
from aivm.scoped_store import resolve_store_scope, load_scope_store, save_scope_store
from aivm.config_store.resolve import find_vm, find_network

payload = json.load(sys.stdin)
ctx, store_path = load_vm_context_with_path(
    payload.get('aivm_config'), vm_opt=payload.get('vm', ''),
    host_src=None, hydrate_runtime_defaults=True,
    persist_runtime_defaults=False,
)
scope = resolve_store_scope(str(store_path))
store = load_scope_store(scope)
vm_name = ctx.effective_cfg.vm.name
vm = find_vm(store, vm_name)
if vm is None:
    raise RuntimeError('AIVM VM not found: ' + vm_name)
network = find_network(store, vm.network_name)
if network is None:
    raise RuntimeError('Network not found: ' + vm.network_name)
if not network.network.gateway_ip:
    raise RuntimeError('AIVM network has no gateway_ip')

changed = False
endpoint = payload.get('allow_endpoint')
if endpoint:
    if not network.firewall.enabled:
        raise RuntimeError('Refusing to edit firewall exceptions: firewall is disabled')
    allow = network.firewall.allow_tcp_endpoints
    if endpoint not in allow:
        allow.append(endpoint)
        save_scope_store(
            scope, store,
            reason='Allow AIVM VM network to reach local infer-stack LiteLLM gateway.',
        )
        changed = True

result = {
    'vm': vm_name,
    'network': vm.network_name,
    'network_vm_names': [v.name for v in store.vms if v.network_name == vm.network_name],
    'gateway_ip': network.network.gateway_ip,
    'firewall_enabled': bool(network.firewall.enabled),
    'allowed_endpoints': network.firewall.allow_tcp_endpoints,
    'guest_user': ctx.guest_user,
    'ssh_identity_file': ctx.effective_cfg.paths.ssh_identity_file or ctx.profile.ssh_identity_file,
    'state_dir': ctx.effective_cfg.paths.state_dir,
    'changed': changed,
}
print('PI_VM_SETUP_JSON:' + json.dumps(result, separators=(',', ':')))
'''

GUEST_CONFIGURE = r'''
import json
import os
from pathlib import Path
import stat
import sys
import tempfile
from urllib.request import Request, urlopen

payload = json.load(sys.stdin)
base = Path.home() / '.pi' / 'agent'
base.mkdir(parents=True, exist_ok=True, mode=0o700)

def read_config(name):
    path = base / name
    if path.is_symlink():
        raise RuntimeError('Refusing symlinked Pi config: ' + name)
    if not path.exists():
        return {}, path
    data = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(data, dict):
        raise RuntimeError(name + ' is not a JSON object')
    return data, path

def atomic_json(path, value):
    fd, temp = tempfile.mkstemp(prefix='.' + path.name + '.', dir=path.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as stream:
            os.fchmod(stream.fileno(), 0o600)
            json.dump(value, stream, ensure_ascii=False, indent=2)
            stream.write('\n')
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp, path)
        os.chmod(path, 0o600)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)

settings, settings_path = read_config('settings.json')
auth, auth_path = read_config('auth.json')
for key, value in payload['preferences'].items():
    settings[key] = value
settings['defaultProvider'] = 'litellm'
settings['defaultModel'] = payload['model']
packages = settings.setdefault('packages', [])
if not isinstance(packages, list):
    raise RuntimeError('settings.packages is not an array')
package = payload['package']
if not any(isinstance(p, str) and (p == package or p.startswith(package + '@')) for p in packages):
    packages.append(package)
config = settings.setdefault('litellm', {})
if not isinstance(config, dict):
    raise RuntimeError('settings.litellm is not an object')
providers = config.setdefault('providers', {})
if not isinstance(providers, dict):
    raise RuntimeError('settings.litellm.providers is not an object')
provider = providers.setdefault('litellm', {})
if not isinstance(provider, dict):
    raise RuntimeError('settings.litellm.providers.litellm is not an object')
provider['baseUrl'] = payload['gateway_url']
provider['allowInsecureHttp'] = payload['gateway_url'].startswith('http://')
# The credential lives only in auth.json, not also in settings.json.
provider.pop('apiKey', None)
auth['litellm'] = {
    'type': 'api_key',
    'key': payload['key'],
    'env': {'LITELLM_BASE_URL': payload['gateway_url']},
}
if not settings_path.exists() or settings != read_config('settings.json')[0]:
    atomic_json(settings_path, settings)
else:
    os.chmod(settings_path, 0o600)
if not auth_path.exists() or auth != read_config('auth.json')[0]:
    atomic_json(auth_path, auth)
else:
    os.chmod(auth_path, 0o600)

# Probe from inside the VM: host-local health alone does not prove VM routing.
url = payload['gateway_url'].rstrip('/') + '/v1/models'
req = Request(url, headers={'Authorization': 'Bearer ' + payload['key']})
try:
    with urlopen(req, timeout=15) as response:
        models = json.load(response).get('data', [])
except Exception as ex:
    raise RuntimeError('VM cannot authenticate to gateway at ' + url +
                       ': ' + type(ex).__name__) from None
ids = {m.get('id') for m in models if isinstance(m, dict)}
if payload['model'] not in ids:
    raise RuntimeError('VM reached gateway, but default model is not listed: ' + payload['model'])
print('Guest Pi settings/auth updated; VM gateway probe passed; models=' + str(len(ids)))
'''


class SetupError(RuntimeError):
    pass


def command(argv: list[str], *, input_text: str | None = None, timeout: int = 40) -> str:
    try:
        proc = subprocess.run(
            argv, input=input_text, capture_output=True, text=True,
            timeout=timeout, check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as ex:
        raise SetupError(f'Command failed: {shlex.join(argv[:4])}: {type(ex).__name__}') from None
    if proc.returncode:
        # Never print stdin or the full command to avoid inadvertently logging credentials.
        err = (proc.stderr or '').strip()
        err = '\n'.join(err.splitlines()[-8:])
        raise SetupError(f'{argv[0]} exited {proc.returncode}: {err or "no diagnostic"}')
    return proc.stdout


def detect_aivm_interpreter(override: str | None = None) -> str:
    if override:
        candidates = [override]
    else:
        candidates = [sys.executable]
        executable = shutil.which('aivm')
        if not executable:
            raise SetupError('aivm command not found on PATH')
        try:
            launcher = Path(executable).resolve().open('rb')
            with launcher:
                first_line = launcher.readline(512).decode('utf-8', errors='replace').strip()
            if first_line.startswith('#!'):
                shebang = shlex.split(first_line[2:])
                if shebang and Path(shebang[0]).name == 'env':
                    shebang = shebang[1:]
                    if shebang[:1] == ['-S']:
                        shebang = shebang[1:]
                    if shebang:
                        interpreter = shutil.which(shebang[0])
                        if interpreter:
                            candidates.append(interpreter)
                elif shebang:
                    candidates.append(shebang[0])
        except (OSError, ValueError):
            pass
    for candidate in dict.fromkeys(candidates):
        try:
            result = subprocess.run(
                [candidate, '-c', 'import aivm, aivm.scoped_store'],
                capture_output=True, timeout=10, check=False,
            )
            if result.returncode == 0:
                return candidate
        except (OSError, subprocess.TimeoutExpired):
            pass
    raise SetupError(
        'Cannot import aivm from the script Python or the aivm CLI interpreter. '
        'Pass --aivm-python with the interpreter used to install aivm.'
    )


def aivm_info(python: str, vm: str | None, config: str | None,
              allow_endpoint: str | None = None) -> dict:
    payload = {'vm': vm or '', 'aivm_config': config, 'allow_endpoint': allow_endpoint}
    output = command([python, '-c', AIVM_BRIDGE],
                     input_text=json.dumps(payload), timeout=45)
    for line in reversed(output.splitlines()):
        if line.startswith(MARKER):
            return json.loads(line[len(MARKER):])
    raise SetupError('AIVM helper did not return VM metadata')


def infer_env(name: str) -> str:
    value = command(['infer-stack', 'env', name], timeout=20).strip()
    if not value or '\n' in value:
        raise SetupError(f'infer-stack env {name} did not return one value')
    return value


def gateway_models(host_base_url: str, key: str) -> list[str]:
    base = host_base_url.rstrip('/')
    if not base.endswith('/v1'):
        base += '/v1'
    url = base + '/models'
    req = Request(url, headers={'Authorization': 'Bearer ' + key})
    try:
        with urlopen(req, timeout=12) as response:
            document = json.load(response)
    except HTTPError as ex:
        raise SetupError(f'LiteLLM HTTP {ex.code} at {url}') from None
    except (URLError, OSError, ValueError) as ex:
        raise SetupError(f'Cannot query LiteLLM {url}: {type(ex).__name__}') from None
    if not isinstance(document, dict) or not isinstance(document.get('data'), list):
        raise SetupError('LiteLLM /v1/models did not contain a data array')
    return sorted({entry['id'] for entry in document['data']
                   if isinstance(entry, dict) and isinstance(entry.get('id'), str)})


def select_model(requested: str | None, available: list[str]) -> str:
    if requested:
        model = requested.removeprefix('litellm/')
        if model not in available:
            raise SetupError(f'Model {model!r} is not in the LiteLLM catalog.\n'
                             + '\n'.join('  ' + item for item in available))
        return model
    if len(available) == 1:
        return available[0]
    if not available:
        raise SetupError('LiteLLM returned no models: acquire a model before configuring Pi')
    if not sys.stdin.isatty():
        raise SetupError('Several models available; specify --model:\n'
                         + '\n'.join('  ' + item for item in available))
    print('Choose Pi default model:')
    for index, name in enumerate(available, 1):
        print(f'  {index:2d}. {name}')
    raw = input('Model number: ').strip()
    try:
        index = int(raw)
    except ValueError:
        raise SetupError('Expected a numeric model selection') from None
    if not 1 <= index <= len(available):
        raise SetupError('Model number out of range')
    return available[index - 1]


def load_preferences(path: str | None) -> dict:
    result = copy.deepcopy(DEFAULT_PREFERENCES)
    if path is None:
        return result
    config_path = Path(path).expanduser()
    try:
        data = json.loads(config_path.read_text(encoding='utf-8'))
    except (OSError, ValueError) as ex:
        raise SetupError(f'Could not read Pi preferences at {config_path}: {ex}') from None
    if not isinstance(data, dict):
        raise SetupError('Pi settings source must contain a JSON object')
    for key in COPYABLE_KEYS:
        if key in data:
            result[key] = copy.deepcopy(data[key])
    return result


def discover_ip(vm: str, state_dir: str, override: str | None = None) -> str:
    if override:
        try:
            return str(ipaddress.IPv4Address(override))
        except ipaddress.AddressValueError:
            raise SetupError('--ssh-ip must be an IPv4 address') from None
    try:
        output = command(
            ['virsh', '-c', 'qemu:///system', 'domifaddr', vm, '--source', 'lease'],
            timeout=12,
        )
        ips = re.findall(r'(?<![\d.])((?:\d{1,3}\.){3}\d{1,3})/\d{1,2}\b', output)
        for candidate in ips:
            address = ipaddress.IPv4Address(candidate)
            if not address.is_loopback and not address.is_link_local:
                return str(address)
    except (SetupError, ipaddress.AddressValueError):
        pass
    state_dir_path = Path(os.path.expandvars(state_dir)).expanduser()
    cached = state_dir_path / vm / (vm + '.ip')
    if cached.is_file():
        try:
            return str(ipaddress.IPv4Address(cached.read_text().strip()))
        except (OSError, ipaddress.AddressValueError):
            pass
    raise SetupError(
        f'Could not find IPv4 for {vm}. Check virsh domifaddr and AIVM IP cache '
        'or supply --ssh-ip ADDRESS.'
    )


def ssh_command(info: dict, ip: str, remote: str) -> list[str]:
    identity = Path(os.path.expandvars(info['ssh_identity_file'])).expanduser()
    if not identity.is_file():
        raise SetupError(f'AIVM SSH identity not found: {identity}')
    user = info['guest_user']
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.-]*', user):
        raise SetupError('AIVM guest username is malformed')
    return [
        'ssh', '-T', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
        '-o', 'StrictHostKeyChecking=accept-new', '-o', 'IdentitiesOnly=yes',
        '-o', 'ForwardAgent=no', '-i', str(identity), f'{user}@{ip}',
        'bash -lc ' + shlex.quote(remote),
    ]


def remote_run(info: dict, ip: str, shell: str, *, data: dict | None = None,
               timeout: int = 240) -> str:
    return command(ssh_command(info, ip, shell),
                   input_text=json.dumps(data) if data is not None else None,
                   timeout=timeout)


def require_confirmation(message: str, yes: bool) -> None:
    if yes:
        return
    if not sys.stdin.isatty():
        raise SetupError(message + ' (re-run with --yes)')
    if input(message + ' [y/N]: ').strip().lower() not in {'y', 'yes'}:
        raise SetupError('Cancelled; no settings changed')


def parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--vm', help='AIVM VM name (defaults to active VM)')
    p.add_argument('--model', help='LiteLLM route id; prompted if multiple models')
    p.add_argument('--settings-from', metavar='FILE',
                   help='Copy safe preference fields from a local Pi settings.json')
    p.add_argument('--aivm-config', help='Explicit AIVM config store (if nondefault)')
    p.add_argument('--aivm-python', help='Python interpreter containing the installed aivm package')
    p.add_argument('--ssh-ip', help='Override detected guest IPv4 address')
    p.add_argument('--gateway-ip', help='Override AIVM bridge gateway IPv4 address')
    p.add_argument('--gateway-port', type=int, help='Override infer-stack gateway host port')
    p.add_argument('--plugin', default=PACKAGE, help='Pi npm extension package')
    p.add_argument('--list-models', action='store_true', help='List infer-stack routes, then exit')
    p.add_argument('--skip-firewall', action='store_true',
                   help='Do not add AIVM destination firewall exception')
    p.add_argument('--smoke', action='store_true',
                   help='Run one real Pi completion (uses inference tokens)')
    p.add_argument('--dry-run', action='store_true',
                   help='Inspect settings; no API key, firewall writes or SSH connections')
    p.add_argument('--yes', action='store_true', help='Allow network-scoped firewall changes')
    return p


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    if not shutil.which('infer-stack'):
        raise SetupError('infer-stack not found on PATH')
    host_base_url = infer_env('OPENAI_BASE_URL')
    split = urlsplit(host_base_url)
    if split.scheme not in {'http', 'https'} or not split.hostname:
        raise SetupError('infer-stack returned an invalid OPENAI_BASE_URL')
    # Model listing only needs the already-configured host-local gateway.
    # It must not depend on a host-published port or an installed AIVM.
    if args.list_models:
        available = gateway_models(host_base_url, infer_env('LITELLM_MASTER_KEY'))
        for model in available:
            print(model)
        return 0
    if args.gateway_port is not None and not 1 <= args.gateway_port <= 65535:
        raise SetupError('--gateway-port must be between 1 and 65535')
    if args.gateway_port is not None:
        port = args.gateway_port
    else:
        port_value = infer_env('LITELLM_PORT')
        try:
            port = int(port_value)
        except ValueError:
            raise SetupError('infer-stack LITELLM_PORT is not numeric') from None
    if not 1 <= port <= 65535:
        raise SetupError('infer-stack gateway port is out of range')

    python = detect_aivm_interpreter(args.aivm_python)
    info = aivm_info(python, args.vm, args.aivm_config)
    gateway_ip = args.gateway_ip or info['gateway_ip']
    try:
        gateway_ip = str(ipaddress.IPv4Address(gateway_ip))
    except ipaddress.AddressValueError:
        raise SetupError('AIVM gateway_ip is not a valid IPv4 address') from None
    guest_url = f'http://{gateway_ip}:{port}'
    endpoint = f'{gateway_ip}:{port}'
    needed = info['firewall_enabled'] and endpoint not in info['allowed_endpoints']
    if args.dry_run:
        print('Dry run (no credentials accessed):')
        print(f"  VM:          {info['vm']} (network: {info['network']})")
        print(f'  Guest URL:   {guest_url}')
        print(f'  Model:       {args.model or "<prompt/auto-select in live mode>"}')
        print(f'  Pi plugin:   {args.plugin}')
        print(f"  Firewall:    {'add ' + endpoint if needed and not args.skip_firewall else 'unchanged'}")
        print(f"  Preferences: {args.settings_from or 'built-in theme/compaction/retry defaults'}")
        print('  Guest:       global Pi package, settings.json and auth.json (0600)')
        return 0

    key = infer_env('LITELLM_MASTER_KEY')
    available = gateway_models(host_base_url, key)
    model = select_model(args.model, available)
    preferences = load_preferences(args.settings_from)
    print(f"AIVM VM: {info['vm']}; network: {info['network']}; gateway: {guest_url}")
    print(f'Model: {model}')
    if info['firewall_enabled'] and needed:
        if args.skip_firewall:
            print(f'WARNING: AIVM firewall may block {endpoint}; --skip-firewall requested.')
        else:
            affected = ', '.join(info['network_vm_names'])
            require_confirmation(
                f'Permit TCP {endpoint} for AIVM network {info["network"]} '
                f'(shared by: {affected})?', args.yes,
            )
            changed = aivm_info(python, args.vm, args.aivm_config, endpoint)['changed']
            if changed:
                print('AIVM firewall config updated; reconciling with aivm vm update.')
                # Prevent unexpected VM reboots; an update may still reconcile
                # unrelated pending drift (called out in the README).
                command(['aivm', 'vm', 'update', '--vm', info['vm'],
                         '--yes', '--restart', 'never'], timeout=120)

    ip = discover_ip(info['vm'], info['state_dir'], args.ssh_ip)
    print(f"Guest SSH: {info['guest_user']}@{ip}")
    install_shell = '''set -eu
if command -v pi >/dev/null 2>&1; then
  PI=pi
elif [ -x "$HOME/.local/bin/pi" ]; then
  PI="$HOME/.local/bin/pi"
else
  echo 'Pi is not installed; run aivm vm provision pi on the host' >&2
  exit 17
fi
"$PI" install ''' + shlex.quote(args.plugin)
    print('Installing Pi LiteLLM extension (personal/global scope)...')
    remote_run(info, ip, install_shell, timeout=300)
    print('Writing Pi settings and auth (credential sent over SSH stdin)...')
    payload = {
        'preferences': preferences, 'model': model, 'key': key,
        'gateway_url': guest_url, 'package': args.plugin,
    }
    result = remote_run(
        info, ip, 'python3 -c ' + shlex.quote(GUEST_CONFIGURE),
        data=payload, timeout=60,
    )
    print(result.strip())
    if args.smoke:
        print('Running Pi completion smoke test...')
        # No token or key appears in the remote command.
        shell = (
            'if command -v pi >/dev/null 2>&1; then PI=pi; '
            'else PI="$HOME/.local/bin/pi"; fi; '
            '"$PI" --no-session --print --provider litellm --model '
            + shlex.quote(model) + " 'Reply with OK.'"
        )
        print(remote_run(info, ip, shell, timeout=240).strip())
    print('Setup completed. Connect with: aivm vm ssh --vm ' + shlex.quote(info['vm']))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (SetupError, KeyboardInterrupt) as exc:
        print(f'pi-vm-setup: {exc or "Interrupted"}', file=sys.stderr)
        raise SystemExit(2)
