#!/usr/bin/env python3
"""
setup_agent_vm.py

Planner/driver that writes a reviewable .env + bash scripts to set up an isolated
Ubuntu 24.04 KVM VM suitable for VS Code Remote-SSH.

Usage:
  python3 setup_agent_vm.py plan [--outdir agentvm_plan]
  python3 setup_agent_vm.py apply [--outdir agentvm_plan] [--interactive|--yes]
  python3 setup_agent_vm.py clean [--outdir agentvm_plan]
"""

from __future__ import annotations

import argparse
import logging
import ipaddress
import os
import re
import shutil
import subprocess
import sys
import textwrap
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

LOGGER = logging.getLogger(__name__)


# ----------------------------- Utilities -----------------------------

def run_capture(cmd: List[str], check: bool = False) -> Tuple[int, str, str]:
    p = subprocess.run(cmd, text=True, capture_output=True)
    if check and p.returncode != 0:
        raise RuntimeError(f"Command failed: {cmd}\nstdout:\n{p.stdout}\nstderr:\n{p.stderr}")
    return p.returncode, p.stdout, p.stderr


def which(cmd: str) -> Optional[str]:
    return shutil.which(cmd)


def read_os_release() -> Dict[str, str]:
    path = Path("/etc/os-release")
    if not path.exists():
        return {}
    data: Dict[str, str] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        v = v.strip().strip('"')
        data[k.strip()] = v
    return data


def is_debian_like(osr: Dict[str, str]) -> bool:
    id_ = (osr.get("ID") or "").lower()
    like = (osr.get("ID_LIKE") or "").lower()
    return any(x in (id_ + " " + like) for x in ["debian", "ubuntu"])


def systemctl_is_active(service: str) -> bool:
    if which("systemctl") is None:
        return False
    code, _, _ = run_capture(["systemctl", "is-active", "--quiet", service])
    return code == 0


def guess_firewall_backend() -> str:
    """
    Return: "firewalld" | "nft" | "unknown"
    """
    if systemctl_is_active("firewalld") and which("firewall-cmd"):
        return "firewalld"
    if which("nft"):
        return "nft"
    return "unknown"


def parse_ipv4_routes() -> List[ipaddress.IPv4Network]:
    """
    Parse `ip -4 route show` prefixes into networks.
    """
    if which("ip") is None:
        return []
    code, out, _ = run_capture(["ip", "-4", "route", "show"], check=False)
    if code != 0:
        return []
    nets: List[ipaddress.IPv4Network] = []
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        tok = line.split()[0]
        if "/" in tok:
            try:
                nets.append(ipaddress.ip_network(tok, strict=False))
            except ValueError:
                pass
    return nets


def overlaps_any(target: ipaddress.IPv4Network, existing: List[ipaddress.IPv4Network]) -> bool:
    return any(target.overlaps(n) for n in existing)


def pick_free_subnet(existing_routes: List[ipaddress.IPv4Network]) -> Optional[ipaddress.IPv4Network]:
    """
    Try a couple candidate pools that usually avoid common LAN/VPN defaults.
    """
    pools = []
    pools.extend([ipaddress.ip_network(f"10.77.{x}.0/24") for x in range(0, 256)])
    pools.extend([ipaddress.ip_network(f"172.27.{x}.0/24") for x in range(0, 256)])
    for cand in pools:
        if not overlaps_any(cand, existing_routes):
            return cand
    return None


def cidr_to_gateway_and_dhcp(cidr: ipaddress.IPv4Network) -> Tuple[str, str, str]:
    """
    For /24: gateway=.1, dhcp range .50-.200
    """
    if cidr.prefixlen != 24:
        raise ValueError("Only /24 supported in this planner for now.")
    net_int = int(cidr.network_address)
    gw = str(ipaddress.ip_address(net_int + 1))
    dhcp_start = str(ipaddress.ip_address(net_int + 50))
    dhcp_end = str(ipaddress.ip_address(net_int + 200))
    return gw, dhcp_start, dhcp_end


def best_default_ssh_identity() -> Optional[Path]:
    """
    Use ssh -G trick to find an IdentityFile the user's SSH client would pick.
    Preference: first identityfile that exists and is not 'none'.
    """
    if which("ssh") is None:
        return None
    code, out, _ = run_capture(["ssh", "-G", "unknown@doesnt.exist"], check=False)
    if code != 0 and not out:
        return None

    candidates: List[Path] = []
    for line in out.splitlines():
        parts = line.strip().split()
        if len(parts) >= 2 and parts[0].lower() == "identityfile":
            val = parts[1].strip()
            if val.lower() == "none":
                continue
            # ssh -G can emit quoted paths or ~
            val = os.path.expanduser(val)
            candidates.append(Path(val))

    for p in candidates:
        if p.exists():
            return p

    # fallback to common keys
    fallbacks = [
        Path.home() / ".ssh" / "id_ed25519",
        Path.home() / ".ssh" / "id_rsa",
    ]
    for p in fallbacks:
        if p.exists():
            return p
    return None


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def write_text(path: Path, content: str, mode: int = 0o644) -> None:
    path.write_text(content)
    os.chmod(path, mode)




def parse_env_file(path: Path) -> Dict[str, str]:
    """Parse a simple KEY=VALUE .env file (comments and blank lines ignored)."""
    env: Dict[str, str] = {}
    if not path.exists():
        return env
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip()
        if not k:
            continue
        if len(v) >= 2 and ((v[0] == '"' and v[-1] == '"') or (v[0] == "'" and v[-1] == "'")):
            v = v[1:-1]
        v = v.replace(r'\"', '"')
        env[k] = v
    return env


def apply_overrides(base: Dict[str, str], overrides: Dict[str, str]) -> Dict[str, str]:
    out = dict(base)
    out.update(overrides)
    return out


def apply_kv_overrides(base: Dict[str, str], kvs: List[str]) -> Dict[str, str]:
    out = dict(base)
    for item in kvs:
        if "=" not in item:
            raise ValueError(f"--set expects KEY=VALUE, got: {item!r}")
        k, v = item.split("=", 1)
        out[k.strip()] = v
    return out


def fill_derived_env(env: Dict[str, str], notes: List[str]) -> Dict[str, str]:
    """Fill derived values when upstream knobs are provided."""
    out = dict(env)

    ssh_id = out.get("SSH_IDENTITY_FILE", "").strip()
    if ssh_id and not out.get("SSH_PUBKEY_PATH", "").strip():
        out["SSH_PUBKEY_PATH"] = ssh_id + ".pub"

    cidr_s = out.get("NET_SUBNET_CIDR", "").strip()
    if cidr_s:
        try:
            net = ipaddress.ip_network(cidr_s, strict=False)
            if isinstance(net, ipaddress.IPv4Network):
                if net.prefixlen == 24:
                    gw, dhcp_start, dhcp_end = cidr_to_gateway_and_dhcp(net)
                    out.setdefault("NET_GATEWAY_IP", gw)
                    out.setdefault("DHCP_START", dhcp_start)
                    out.setdefault("DHCP_END", dhcp_end)
                else:
                    notes.append("NET_SUBNET_CIDR is not /24; planner only derives DHCP and gateway for /24.")
        except Exception:
            notes.append(f"Could not parse NET_SUBNET_CIDR={cidr_s!r}; leaving derived fields unchanged.")

    net_name = out.get("NET_NAME", "").strip()
    if net_name:
        bridge = f"virbr-{net_name}"
        if len(bridge) > 15:
            notes.append(
                f"NET_NAME={net_name!r} will create bridge {bridge!r} (len={len(bridge)}), "
                "but Linux interface names must be <= 15. Shorten NET_NAME."
            )

    return out

# ----------------------------- Plan Model -----------------------------

@dataclass
class Plan:
    outdir: Path
    env: Dict[str, str]
    notes: List[str]


def build_plan(outdir: Path) -> Plan:
    osr = read_os_release()
    notes: List[str] = []

    if not osr:
        notes.append("Could not read /etc/os-release; distro detection may be incomplete.")

    if osr and not is_debian_like(osr):
        notes.append("Host does not look Debian/Ubuntu-like. Plan will generate scripts, but host deps step is Debian-focused.")

    firewall_backend = guess_firewall_backend()
    if firewall_backend == "unknown":
        notes.append("Could not detect nftables or firewalld. Isolation rules may be skipped until you install nftables or enable firewalld.")

    routes = parse_ipv4_routes()
    free = pick_free_subnet(routes)
    if free is None:
        notes.append("Could not auto-pick a free /24 from candidate pools. You will need to set NET_SUBNET_CIDR manually in .env.")
        net_cidr = ""
        gw, dhcp_start, dhcp_end = "", "", ""
    else:
        net_cidr = str(free)
        gw, dhcp_start, dhcp_end = cidr_to_gateway_and_dhcp(free)

    identity = best_default_ssh_identity()
    if identity is None:
        notes.append("Could not determine an SSH identity file automatically. Set SSH_IDENTITY_FILE in .env (and ensure a matching .pub exists).")
        ssh_identity = str(Path.home() / ".ssh" / "id_ed25519")
    else:
        ssh_identity = str(identity)

    # derive pub key path
    pub_guess = ssh_identity + ".pub"

    env = {
        # VM settings
        "VM_NAME": "agentvm-2404",
        "VM_USER": "agent",
        "VM_CPUS": "4",
        "VM_RAM_MB": "8192",
        "VM_DISK_GB": "60",

        # Network settings
        "NET_NAME": "agentvm-net",
        "NET_SUBNET_CIDR": net_cidr,
        "NET_GATEWAY_IP": gw,
        "DHCP_START": dhcp_start,
        "DHCP_END": dhcp_end,

        # Image settings
        "UBUNTU_IMG_URL": "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img",

        "BASE_IMG_PATH": "/var/lib/libvirt/agentvm/images/noble-base.img",
        "REDOWNLOAD_BASE_IMAGE": "0",

        # Paths (review before apply if you prefer different locations)
        "BASE_DIR": "/var/lib/libvirt/agentvm",
        "IMG_DIR": "/var/lib/libvirt/agentvm/images",
        "CI_DIR": "/var/lib/libvirt/agentvm/cloud-init",

        # SSH identity (private key); scripts will use SSH_PUBKEY_PATH for cloud-init
        "SSH_IDENTITY_FILE": ssh_identity,
        "SSH_PUBKEY_PATH": pub_guess,

        # SSH password login (less secure; stored in plan .env)
        "ALLOW_PASSWORD_LOGIN": "1",
        "VM_PASSWORD": "agent",

        # Optional host path sharing (intentional break in isolation model)
        "ENABLE_SHARE_PATHS": "0",
        "HOST_SHARE_SRC": "",
        "HOST_SHARE_TAG": "hostcode",
        "HOST_SHARE_MOUNT": "/mnt/hostcode",
        "HOST_SHARE_MOUNT_OPTS": "nodev,nosuid,noexec",

        # Optional provisioning inside the VM
        "ENABLE_PROVISION": "0",

        # Firewall backend
        "FIREWALL_BACKEND": firewall_backend,

        "ENABLE_FIREWALL": "1",

        # Behavior
        "UPDATE": "",  # set to "1" to run apt update before installs
        "RECREATE": "0",
        "DRY_RUN": "0",
    }

    return Plan(outdir=outdir, env=env, notes=notes)


# ----------------------------- Script Templates -----------------------------

def env_file_contents(env: Dict[str, str]) -> str:
    lines = []
    lines.append("# agentvm_plan .env")
    lines.append("# Edit this file to customize behavior before `apply`.")
    lines.append("#")
    for k in sorted(env.keys()):
        v = env[k]
        # Quote values that contain spaces or are empty
        if v == "" or re.search(r"\s", v):
            vq = '"' + v.replace('"', '\\"') + '"'
        else:
            vq = v
        lines.append(f"{k}={vq}")
    lines.append("")
    return "\n".join(lines)


COMMON_SH = r"""#!/usr/bin/env bash
set -euo pipefail

# Source env (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PLAN_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Missing $ENV_FILE. Run: python3 setup_agent_vm.py plan" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

log(){ printf '%s\n' "$*"; }
info(){ log "INFO: $*"; }
warn(){ log "WARN: $*" >&2; }
die(){ log "ERROR: $*" >&2; exit 1; }

# SUDO only when needed
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    SUDO=""
  fi
fi

run(){
  # Always show commands; respect DRY_RUN=1
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "DRYRUN: $*"
  else
    echo "RUN: $*"
    eval "$@"
  fi
}

require_cmd(){
  local c="$1"
  command -v "$c" >/dev/null 2>&1 || die "Missing required command: $c"
}

# ---------- Debian/Ubuntu apt helpers ----------

apt_ensure(){
    # Checks to see if packages are installed and installs them if needed.
    # Avoids sudo and apt install if everything is already present.
    #
    # Env:
    #   UPDATE: if non-empty, runs apt update before installing missing packages.
    #
    # Usage:
    #   apt_ensure git curl htop
    #
    local ARGS=("$@")
    local MISS_PKGS=()
    local HIT_PKGS=()

    require_cmd dpkg-query
    require_cmd apt

    local _SUDO=""
    if [[ "$(id -u)" -ne 0 ]]; then
      _SUDO="$SUDO"
    fi

    for PKG_NAME in "${ARGS[@]}"; do
      if dpkg-query -W -f='${Status}' "$PKG_NAME" 2>/dev/null | grep -q "install ok installed"; then
          info "Already have PKG_NAME='$PKG_NAME'"
          HIT_PKGS+=("$PKG_NAME")
      else
          warn "Do not have PKG_NAME='$PKG_NAME'"
          MISS_PKGS+=("$PKG_NAME")
      fi
    done

    if [[ "${#MISS_PKGS[@]}" -gt 0 ]]; then
      if [[ "${UPDATE:-}" != "" ]]; then
        run "${_SUDO} apt-get update"
      else
        info "Skipping apt-get update (set UPDATE=1 in .env to enable)"
      fi
      run "DEBIAN_FRONTEND=noninteractive ${_SUDO} apt-get install -y ${MISS_PKGS[*]}"
    else
      info "No missing packages"
    fi
}

os_is_debian_like(){
  [[ -f /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  source /etc/os-release
  local blob="${ID:-} ${ID_LIKE:-}"
  echo "$blob" | grep -qiE '(debian|ubuntu)'
}

"""

HOST_DEPS_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

info "Host deps step (Debian/Ubuntu-focused)."

if ! os_is_debian_like; then
  warn "This host does not look Debian/Ubuntu-like. This script only implements apt_ensure today."
  warn "You can still review the required packages below and install them manually."
  [[ "${DRY_RUN:-0}" == "1" ]] || die "Refusing to proceed on non-Debian in apply mode."
fi

# Install only what's missing (avoids sudo if already installed)
apt_ensure \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  virtinst \
  cloud-image-utils \
  qemu-utils \
  genisoimage \
  curl \
  nftables \
  python3

# Enable libvirt
run "${SUDO} systemctl enable --now libvirtd"

# Optional: ensure nftables service is enabled if present (not critical)
run "${SUDO} systemctl enable --now nftables || true"

info "Host deps complete."
"""

DOWNLOAD_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd curl

: "${UBUNTU_IMG_URL:?UBUNTU_IMG_URL missing}"
: "${IMG_DIR:?IMG_DIR missing}"
: "${BASE_IMG_PATH:?BASE_IMG_PATH missing}"

run "${SUDO} mkdir -p '$IMG_DIR'"

if [[ -f "$BASE_IMG_PATH" && "${REDOWNLOAD_BASE_IMAGE:-0}" != "1" ]]; then
  info "Base image already cached: $BASE_IMG_PATH"
  info "To force re-download: set REDOWNLOAD_BASE_IMAGE=1 in .env"
  exit 0
fi

if [[ -f "$BASE_IMG_PATH" && "${REDOWNLOAD_BASE_IMAGE:-0}" == "1" ]]; then
  warn "REDOWNLOAD_BASE_IMAGE=1; removing cached base image: $BASE_IMG_PATH"
  run "${SUDO} rm -f '$BASE_IMG_PATH'"
fi

info "Downloading Ubuntu cloud image to: $BASE_IMG_PATH"
run "${SUDO} curl -L --fail -o '$BASE_IMG_PATH' '$UBUNTU_IMG_URL'"

info "Download complete."
"""


NETWORK_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd virsh
require_cmd ip
require_cmd python3

: "${NET_NAME:?NET_NAME missing}"
: "${NET_SUBNET_CIDR:?NET_SUBNET_CIDR missing (planner should fill this; set manually if empty)}"
: "${NET_GATEWAY_IP:?NET_GATEWAY_IP missing}"
: "${DHCP_START:?DHCP_START missing}"
: "${DHCP_END:?DHCP_END missing}"

NET_BRIDGE="virbr-${NET_NAME}"

# Linux interface names must be <= 15 chars (IFNAMSIZ=16 including NUL).
if [[ "${#NET_BRIDGE}" -gt 15 ]]; then
  die "Bridge interface name too long: NET_BRIDGE=${NET_BRIDGE} (len=${#NET_BRIDGE} > 15). Choose a shorter NET_NAME so virbr-${NET_NAME} is <= 15 chars."
fi

info "Defining libvirt NAT network '$NET_NAME' on $NET_SUBNET_CIDR (bridge=$NET_BRIDGE)"

# Detect overlap as a safety check (even if planner picked it)
python3 - <<PY
import ipaddress, subprocess, sys
target = ipaddress.ip_network("${NET_SUBNET_CIDR}", strict=False)
routes = subprocess.check_output(["ip","-4","route","show"]).decode().splitlines()
nets=[]
for r in routes:
    tok=r.split()[0]
    if "/" in tok:
        try: nets.append(ipaddress.ip_network(tok, strict=False))
        except ValueError: pass
for n in nets:
    if target.overlaps(n):
        print(f"ERROR: target {target} overlaps existing route {n}")
        sys.exit(2)
sys.exit(0)
PY

# If net exists
if virsh net-info "$NET_NAME" >/dev/null 2>&1; then
  if [[ "${RECREATE:-0}" == "1" ]]; then
    warn "Network exists; destroying/undefining because RECREATE=1"
    run "${SUDO} virsh net-destroy '$NET_NAME' || true"
    run "${SUDO} virsh net-undefine '$NET_NAME' || true"
  else
    die "Network '$NET_NAME' already exists. Set RECREATE=1 or choose a different NET_NAME in .env."
  fi
fi

# Write XML to a temporary file
TMP_XML="$(mktemp)"
cat > "$TMP_XML" <<EOF
<network>
  <name>${NET_NAME}</name>
  <forward mode='nat'/>
  <bridge name='${NET_BRIDGE}' stp='on' delay='0'/>
  <ip address='${NET_GATEWAY_IP}' prefix='24'>
    <dhcp>
      <range start='${DHCP_START}' end='${DHCP_END}'/>
    </dhcp>
  </ip>
</network>
EOF

run "${SUDO} virsh net-define '$TMP_XML'"
run "${SUDO} virsh net-autostart '$NET_NAME'"
run "${SUDO} virsh net-start '$NET_NAME'"

rm -f "$TMP_XML"

info "Network ready."
"""

FIREWALL_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

# nft uses {...} set syntax; bash would expand it unless disabled
set +o braceexpand

: "${NET_NAME:?NET_NAME missing}"
: "${NET_GATEWAY_IP:?NET_GATEWAY_IP missing}"
: "${FIREWALL_BACKEND:?FIREWALL_BACKEND missing}"

if [[ "${ENABLE_FIREWALL:-1}" != "1" ]]; then
  warn "ENABLE_FIREWALL!=1; skipping firewall isolation rules."
  exit 0
fi

NET_BRIDGE="virbr-${NET_NAME}"

info "Applying isolation rules (backend=$FIREWALL_BACKEND, bridge=$NET_BRIDGE)"

if [[ "$FIREWALL_BACKEND" == "firewalld" ]]; then
  require_cmd firewall-cmd
  run "${SUDO} systemctl enable --now firewalld"

  # Apply direct rules (runtime + permanent). Interface-scoped.
  add_direct() {
    local scope="$1"; shift
    local args="$*"
    if [[ "$scope" == "permanent" ]]; then
      run "${SUDO} firewall-cmd --permanent --direct --remove-rule ipv4 filter FORWARD 0 $args >/dev/null 2>&1 || true"
      run "${SUDO} firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 $args"
    else
      run "${SUDO} firewall-cmd --direct --remove-rule ipv4 filter FORWARD 0 $args >/dev/null 2>&1 || true"
      run "${SUDO} firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 $args"
    fi
  }

  # Allow DHCP + DNS to gateway
  add_direct runtime   "-i $NET_BRIDGE -p udp --dport 67:68 -j ACCEPT"
  add_direct runtime   "-i $NET_BRIDGE -d $NET_GATEWAY_IP -p udp --dport 53 -j ACCEPT"
  add_direct runtime   "-i $NET_BRIDGE -d $NET_GATEWAY_IP -p tcp --dport 53 -j ACCEPT"
  # Block other gateway access
  add_direct runtime   "-i $NET_BRIDGE -d $NET_GATEWAY_IP -j DROP"
  # Block RFC1918 + local
  add_direct runtime   "-i $NET_BRIDGE -d 10.0.0.0/8 -j DROP"
  add_direct runtime   "-i $NET_BRIDGE -d 172.16.0.0/12 -j DROP"
  add_direct runtime   "-i $NET_BRIDGE -d 192.168.0.0/16 -j DROP"
  add_direct runtime   "-i $NET_BRIDGE -d 169.254.0.0/16 -j DROP"
  add_direct runtime   "-i $NET_BRIDGE -d 127.0.0.0/8 -j DROP"

  # Permanent equivalents
  add_direct permanent "-i $NET_BRIDGE -p udp --dport 67:68 -j ACCEPT"
  add_direct permanent "-i $NET_BRIDGE -d $NET_GATEWAY_IP -p udp --dport 53 -j ACCEPT"
  add_direct permanent "-i $NET_BRIDGE -d $NET_GATEWAY_IP -p tcp --dport 53 -j ACCEPT"
  add_direct permanent "-i $NET_BRIDGE -d $NET_GATEWAY_IP -j DROP"
  add_direct permanent "-i $NET_BRIDGE -d 10.0.0.0/8 -j DROP"
  add_direct permanent "-i $NET_BRIDGE -d 172.16.0.0/12 -j DROP"
  add_direct permanent "-i $NET_BRIDGE -d 192.168.0.0/16 -j DROP"
  add_direct permanent "-i $NET_BRIDGE -d 169.254.0.0/16 -j DROP"
  add_direct permanent "-i $NET_BRIDGE -d 127.0.0.0/8 -j DROP"

  run "${SUDO} firewall-cmd --reload"
  info "firewalld direct rules applied."

elif [[ "$FIREWALL_BACKEND" == "nft" ]]; then
  require_cmd nft

  # Table exists?
  if ! ${SUDO} nft list table inet agentvm_sandbox >/dev/null 2>&1; then
  run "${SUDO} nft add table inet agentvm_sandbox"
fi

  # Chain exists? then flush
  run "${SUDO} nft list chain inet agentvm_sandbox forward >/dev/null 2>&1 || \
    nft add chain inet agentvm_sandbox forward '{ type filter hook forward priority 0; policy accept; }'"
  run "${SUDO} nft flush chain inet agentvm_sandbox forward"

  # Allow DHCP (client/server ports)
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" udp dport 67-68 accept"

  # Allow DNS to the libvirt gateway only
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP udp dport 53 accept"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP tcp dport 53 accept"

  # Block other gateway access
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP drop"

  # Block RFC1918 + local ranges (no nft set braces; avoid bash eval brace-expansion)
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr 10.0.0.0/8 drop"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr 172.16.0.0/12 drop"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr 192.168.0.0/16 drop"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr 169.254.0.0/16 drop"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr 127.0.0.0/8 drop"

  # Best-effort IPv6 local blocks (also no braces)
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip6 daddr fd00::/8 drop 2>/dev/null || true"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip6 daddr fe80::/10 drop 2>/dev/null || true"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip6 daddr ::1/128 drop 2>/dev/null || true"

  info "nftables isolation rules applied (scoped to iifname=$NET_BRIDGE)."

else
  warn "Unknown firewall backend '$FIREWALL_BACKEND'. Skipping isolation rules."
  warn "Install nftables or enable firewalld, then re-run scripts/30_firewall.sh"
fi
"""


VM_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd qemu-img
require_cmd cloud-localds
require_cmd virt-install
require_cmd virsh

: "${VM_NAME:?VM_NAME missing}"
: "${VM_USER:?VM_USER missing}"
: "${VM_CPUS:?VM_CPUS missing}"
: "${VM_RAM_MB:?VM_RAM_MB missing}"
: "${VM_DISK_GB:?VM_DISK_GB missing}"
: "${NET_NAME:?NET_NAME missing}"
: "${BASE_DIR:?BASE_DIR missing}"
: "${IMG_DIR:?IMG_DIR missing}"
: "${CI_DIR:?CI_DIR missing}"
: "${BASE_IMG_PATH:?BASE_IMG_PATH missing}"
: "${SSH_PUBKEY_PATH:?SSH_PUBKEY_PATH missing}"

# Optional: allow password login (defaults are set by planner)
: "${ALLOW_PASSWORD_LOGIN:=1}"
: "${VM_PASSWORD:=agent}"

# Ensure dirs (need root for /var/lib)
run "${SUDO} mkdir -p '$IMG_DIR' '$CI_DIR' '$BASE_DIR'"

# Ensure the hypervisor (qemu) can traverse/read the image + seed ISO.
ensure_qemu_access() {
  local qemu_user="libvirt-qemu"
  local qemu_grp=""

  if id "$qemu_user" >/dev/null 2>&1; then
    qemu_grp="$(id -gn "$qemu_user")"
  else
    qemu_grp="kvm"
    getent group "$qemu_grp" >/dev/null 2>&1 || qemu_grp="libvirt-qemu"
  fi

  # Parent must be searchable (x) so qemu can traverse into child dirs.
  run "${SUDO} chown -R root:${qemu_grp} '$BASE_DIR'"
  run "${SUDO} chmod 0751 '$BASE_DIR'"

  # Child dirs should be group-traversable/readable.
  run "${SUDO} chown -R root:${qemu_grp} '$IMG_DIR' '$CI_DIR'"
  run "${SUDO} chmod 0750 '$IMG_DIR' '$CI_DIR'"

  # Make existing artifacts group-readable.
  run "${SUDO} find '$IMG_DIR' -maxdepth 1 -type f -name '*.qcow2' -exec chmod 0640 {} + 2>/dev/null || true"
  run "${SUDO} find '$CI_DIR' -maxdepth 1 -type f -name '*-seed.iso' -exec chmod 0640 {} + 2>/dev/null || true"
}

ensure_qemu_access

BASE_IMG="${BASE_IMG_PATH}"
VM_DISK="${IMG_DIR}/${VM_NAME}.qcow2"
SEED_ISO="${CI_DIR}/${VM_NAME}-seed.iso"
USER_DATA="${CI_DIR}/user-data"
META_DATA="${CI_DIR}/meta-data"

# Validate SSH pubkey
if [[ ! -f "$SSH_PUBKEY_PATH" ]]; then
  die "Missing SSH public key at $SSH_PUBKEY_PATH. Ensure SSH_IDENTITY_FILE exists and SSH_PUBKEY_PATH is correct."
fi

# Base image should be present (download step caches it)
if [[ ! -f "$BASE_IMG" ]]; then
  die "Missing base image at $BASE_IMG. Run: bash scripts/15_download_image.sh"
fi

# Create qcow2 overlay
if [[ -f "$VM_DISK" ]]; then
  if [[ "${RECREATE:-0}" == "1" ]]; then
    warn "Removing existing VM disk because RECREATE=1: $VM_DISK"
    run "${SUDO} rm -f '$VM_DISK'"
  else
    info "VM disk exists: $VM_DISK"
  fi
fi

if [[ ! -f "$VM_DISK" ]]; then
  run "${SUDO} qemu-img create -f qcow2 -F qcow2 -b '$BASE_IMG' '$VM_DISK' '${VM_DISK_GB}G'"
fi

# Password login toggles for cloud-init
if [[ "${ALLOW_PASSWORD_LOGIN}" == "1" ]]; then
  if [[ -z "${VM_PASSWORD}" ]]; then
    die "ALLOW_PASSWORD_LOGIN=1 but VM_PASSWORD is empty"
  fi
  SSH_PWAUTH="true"
  LOCK_PASSWD="false"
  CHPASSWD_BLOCK="chpasswd:
  list: |
    ${VM_USER}:${VM_PASSWORD}
  expire: False"
  SSHD_PASS_AUTH="yes"
  SSHD_KBD_AUTH="yes"
else
  SSH_PWAUTH="false"
  LOCK_PASSWD="true"
  CHPASSWD_BLOCK=""
  SSHD_PASS_AUTH="no"
  SSHD_KBD_AUTH="no"
fi

# Write cloud-init
PUBKEY_CONTENT="$(cat "$SSH_PUBKEY_PATH")"
run "${SUDO} bash -lc 'cat > \"$USER_DATA\" <<EOF
#cloud-config
users:
  - name: ${VM_USER}
    groups: [sudo]
    shell: /bin/bash
    sudo: [\"ALL=(ALL) NOPASSWD:ALL\"]
    lock_passwd: ${LOCK_PASSWD}
    ssh_authorized_keys:
      - ${PUBKEY_CONTENT}

ssh_pwauth: ${SSH_PWAUTH}
disable_root: true

${CHPASSWD_BLOCK}

package_update: true
package_upgrade: true
packages:
  - openssh-server
  - ca-certificates
  - curl
  - git
  - python3
  - python3-venv
  - python3-pip
  - build-essential
  - unattended-upgrades

write_files:
  - path: /etc/ssh/sshd_config.d/99-agentvm-hardening.conf
    permissions: \"0644\"
    content: |
      PasswordAuthentication ${SSHD_PASS_AUTH}
      PermitRootLogin no
      KbdInteractiveAuthentication ${SSHD_KBD_AUTH}
      X11Forwarding no
      AllowTcpForwarding yes
      GatewayPorts no

runcmd:
  - systemctl enable --now ssh
  - systemctl enable --now unattended-upgrades || true
EOF'"

run "${SUDO} bash -lc 'cat > \"$META_DATA\" <<EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF'"

run "${SUDO} cloud-localds -v '$SEED_ISO' '$USER_DATA' '$META_DATA'"

ensure_qemu_access

# VM exists?
if virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
  if [[ "${RECREATE:-0}" == "1" ]]; then
    warn "Replacing existing VM because RECREATE=1"
    run "${SUDO} virsh destroy '$VM_NAME' || true"
    run "${SUDO} virsh undefine '$VM_NAME' --remove-all-storage || ${SUDO} virsh undefine '$VM_NAME' || true"
  else
    info "VM already exists: $VM_NAME"
  fi
fi

# Create VM (no shared folders/devices)
if ! virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
  run "${SUDO} virt-install \
    --name '$VM_NAME' \
    --memory '$VM_RAM_MB' \
    --vcpus '$VM_CPUS' \
    --cpu host-passthrough \
    --import \
    --os-variant ubuntu24.04 \
    --disk 'path=$VM_DISK,format=qcow2,bus=virtio' \
    --disk 'path=$SEED_ISO,device=cdrom' \
    --network 'network=$NET_NAME,model=virtio' \
    --graphics none \
    --noautoconsole \
    --rng /dev/urandom \
    --boot uefi"
fi

# Wait for IP
if [[ "${DRY_RUN:-0}" == "1" ]]; then
  info "Dry-run: skipping IP discovery."
  exit 0
fi

info "Waiting for VM IP..."

# Prefer DHCP leases (works without qemu-guest-agent)
MAC="$(${SUDO} virsh domiflist "$VM_NAME" 2>/dev/null | awk 'BEGIN{IGNORECASE=1} $0 ~ /network/ && $0 !~ /^(interface|---)/ {print $NF; exit}' || true)"
if [[ -z "$MAC" ]]; then
  warn "Could not determine VM MAC via virsh domiflist. Try: ${SUDO} virsh domiflist $VM_NAME"
fi

IP=""
for _ in $(seq 1 180); do  # ~6 minutes
  if [[ -n "$MAC" ]]; then
    IP="$(${SUDO} virsh net-dhcp-leases "$NET_NAME" 2>/dev/null | \
      awk -v mac="$MAC" 'BEGIN{IGNORECASE=1} $0 ~ mac {for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/) {print $i; exit}}' | \
      cut -d/ -f1 || true)"
  fi

  # Fallback: domifaddr (often empty unless qemu-guest-agent is installed)
  if [[ -z "$IP" ]]; then
    IP="$(${SUDO} virsh domifaddr "$VM_NAME" 2>/dev/null | awk '/ipv4/ {print $4; exit}' | cut -d/ -f1 || true)"
  fi

  if [[ -n "$IP" ]]; then
    info "VM IP: $IP"
    run "${SUDO} bash -lc 'echo \"$IP\" > \"${BASE_DIR}/${VM_NAME}.ip\"'"
    exit 0
  fi

  sleep 2
done

warn "Timed out discovering VM IP."
warn "Try:"
warn "  ${SUDO} virsh net-dhcp-leases $NET_NAME"
warn "  ${SUDO} virsh console $VM_NAME"
exit 2
"""



SHARE_PATHS_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd virsh
require_cmd awk
require_cmd sed
require_cmd mktemp

: "${VM_NAME:?VM_NAME missing}"
: "${HOST_SHARE_SRC:?HOST_SHARE_SRC missing (set to a host directory to share)}"
: "${HOST_SHARE_TAG:=hostcode}"
: "${HOST_SHARE_MOUNT:=/mnt/hostcode}"
: "${HOST_SHARE_MOUNT_OPTS:=nodev,nosuid,noexec}"

if [[ ! -d "$HOST_SHARE_SRC" ]]; then
  die "HOST_SHARE_SRC=$HOST_SHARE_SRC does not exist or is not a directory."
fi
if [[ "$HOST_SHARE_SRC" == *" "* ]]; then
  die "HOST_SHARE_SRC contains spaces (not supported safely): $HOST_SHARE_SRC"
fi
if ! [[ "$HOST_SHARE_TAG" =~ ^[A-Za-z0-9_.-]+$ ]]; then
  die "HOST_SHARE_TAG must match ^[A-Za-z0-9_.-]+$ (got: $HOST_SHARE_TAG)"
fi

STATE="$(${SUDO} virsh domstate "$VM_NAME" 2>/dev/null || true)"
if echo "$STATE" | grep -qi running; then
  warn "VM $VM_NAME is running. Persisting share requires redefining domain; reboot may be required."
fi

TMPDIR="$(mktemp -d)"
XML_IN="$TMPDIR/domain.xml"
XML_OUT="$TMPDIR/domain.out.xml"
XML_FINAL="$TMPDIR/domain.final.xml"
FS_XML="$TMPDIR/fs.xml"

${SUDO} virsh dumpxml "$VM_NAME" > "$XML_IN"

# Ensure memoryBacking is present for virtiofs (recommended/typically required)
if ! grep -q "<memoryBacking" "$XML_IN"; then
  awk '
    /<\/domain>/ && !done {
      print "  <memoryBacking>"
      print "    <source type='''memfd'''/>"
      print "    <access mode='''shared'''/>"
      print "  </memoryBacking>"
      done=1
    }
    { print }
  ' "$XML_IN" > "$XML_OUT"
else
  cp "$XML_IN" "$XML_OUT"
fi

# Bail if target already exists
if grep -q "<target dir='''${HOST_SHARE_TAG}'''" "$XML_OUT"; then
  die "VM already has a filesystem share with tag/target ${HOST_SHARE_TAG}. Choose a different HOST_SHARE_TAG."
fi

cat > "$FS_XML" <<EOF
  <filesystem type='mount' accessmode='passthrough'>
    <driver type='virtiofs'/>
    <source dir='${HOST_SHARE_SRC}'/>
    <target dir='${HOST_SHARE_TAG}'/>
  </filesystem>
EOF

# Inject filesystem device before </devices>
awk -v insert_file="$FS_XML" '
  BEGIN {
    while ((getline line < insert_file) > 0) ins = ins line "\n"
    close(insert_file)
  }
  /<\/devices>/ && !done {
    printf "%s", ins
    done=1
  }
  { print }
' "$XML_OUT" > "$XML_FINAL"

info "Updating VM definition for $VM_NAME (virtiofs share: $HOST_SHARE_SRC -> tag=$HOST_SHARE_TAG)"
run "${SUDO} virsh define '$XML_FINAL'"

cat <<EOF

Host directory sharing enabled (virtiofs).

Guest mount commands (run inside the VM):
  sudo mkdir -p "$HOST_SHARE_MOUNT"
  sudo mount -t virtiofs -o "$HOST_SHARE_MOUNT_OPTS" "$HOST_SHARE_TAG" "$HOST_SHARE_MOUNT"

Optional: persist across reboots (inside VM):
  echo "$HOST_SHARE_TAG  $HOST_SHARE_MOUNT  virtiofs  $HOST_SHARE_MOUNT_OPTS  0  0" | sudo tee -a /etc/fstab

If the share does not appear immediately, reboot the VM:
  ${SUDO} virsh reboot "$VM_NAME"
(or shutdown/start if reboot does not work)

EOF

rm -rf "$TMPDIR"
"""

PROVISION_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd ssh
require_cmd virsh
require_cmd awk

: "${VM_NAME:?VM_NAME missing}"
: "${VM_USER:?VM_USER missing}"
: "${NET_NAME:?NET_NAME missing}"
: "${BASE_DIR:?BASE_DIR missing}"
: "${SSH_IDENTITY_FILE:?SSH_IDENTITY_FILE missing}"

IP_FILE="${BASE_DIR}/${VM_NAME}.ip"
IP=""
if [[ -f "$IP_FILE" ]]; then
  IP="$(cat "$IP_FILE")"
fi

if [[ -z "$IP" ]]; then
  warn "No IP file at $IP_FILE. Trying DHCP leases..."
  MAC="$(${SUDO} virsh domiflist "$VM_NAME" 2>/dev/null | awk 'BEGIN{IGNORECASE=1} $0 ~ /network/ && $0 !~ /^(interface|---)/ {print $NF; exit}' || true)"
  if [[ -n "$MAC" ]]; then
    IP="$(${SUDO} virsh net-dhcp-leases "$NET_NAME" 2>/dev/null |       awk -v mac="$MAC" 'BEGIN{IGNORECASE=1} $0 ~ mac {for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/) {print $i; exit}}' |       cut -d/ -f1 || true)"
  fi
fi

if [[ -z "$IP" ]]; then
  die "Unable to determine VM IP. Try: ${SUDO} virsh net-dhcp-leases $NET_NAME"
fi

SSH_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${BASE_DIR}/known_hosts -i ${SSH_IDENTITY_FILE}"

info "Provisioning dev tools on ${VM_USER}@${IP} ..."

run "ssh ${SSH_OPTS} ${VM_USER}@${IP} 'sudo apt-get update -y'"
run "ssh ${SSH_OPTS} ${VM_USER}@${IP} 'sudo apt-get install -y docker.io docker-compose git jq ripgrep fd-find tmux htop unzip ca-certificates curl'"
run "ssh ${SSH_OPTS} ${VM_USER}@${IP} 'sudo usermod -aG docker ${VM_USER} || true'"

info "Provisioning complete."
info "Note: docker group membership may require a new SSH session to take effect."
"""


PRINT_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

IP_FILE="${BASE_DIR}/${VM_NAME}.ip"
IP="<unknown>"
if [[ -f "$IP_FILE" ]]; then
  IP="$(cat "$IP_FILE")"
fi

cat <<EOF

==================== RESULT ====================

VM:
  Name : $VM_NAME
  User : $VM_USER
  IP   : $IP

Connect:
  ssh -i "$SSH_IDENTITY_FILE" ${VM_USER}@${IP}

VS Code Remote-SSH:
  Add this to ~/.ssh/config on the machine running VS Code:

Host ${VM_NAME}
  HostName ${IP}
  User ${VM_USER}
  IdentityFile ${SSH_IDENTITY_FILE}
  IdentitiesOnly yes

(Remote-SSH will install the VS Code server automatically on first connect.)

Status commands:
  VM state:
    ${SUDO} virsh domstate "$VM_NAME"
  VM interfaces:
    ${SUDO} virsh domiflist "$VM_NAME"
  VM addresses (may require qemu-guest-agent):
    ${SUDO} virsh domifaddr "$VM_NAME"

  Network state:
    ${SUDO} virsh net-info "$NET_NAME"
  DHCP leases:
    ${SUDO} virsh net-dhcp-leases "$NET_NAME"

  Firewall (nftables):
    ${SUDO} nft list table inet agentvm_sandbox || true
    ${SUDO} nft list ruleset | sed -n '/table inet agentvm_sandbox/,/}/p' || true

  Firewall (firewalld direct rules):
    ${SUDO} firewall-cmd --direct --get-all-rules | grep "virbr-$NET_NAME" || true

Rollback:
  ${SUDO} virsh destroy '$VM_NAME' || true
  ${SUDO} virsh undefine '$VM_NAME' --remove-all-storage || ${SUDO} virsh undefine '$VM_NAME' || true
  ${SUDO} virsh net-destroy '$NET_NAME' || true
  ${SUDO} virsh net-undefine '$NET_NAME' || true
  # If nft used:
  ${SUDO} nft delete table inet agentvm_sandbox || true

===============================================

EOF
"""


DESTROY_SH = r"""#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_common.sh"

require_cmd virsh

info "Destroying VM/network + removing firewall rules (best-effort)."

NET_BRIDGE="virbr-${NET_NAME}"

if virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
  run "${SUDO} virsh destroy '$VM_NAME' || true"
  run "${SUDO} virsh undefine '$VM_NAME' --remove-all-storage || ${SUDO} virsh undefine '$VM_NAME' || true"
fi

if virsh net-info "$NET_NAME" >/dev/null 2>&1; then
  run "${SUDO} virsh net-destroy '$NET_NAME' || true"
  run "${SUDO} virsh net-undefine '$NET_NAME' || true"
fi

if [[ "${FIREWALL_BACKEND:-}" == "firewalld" ]]; then
  warn "firewalld direct rule cleanup is manual (rules are interface-scoped to $NET_BRIDGE)."
  warn "List direct rules: sudo firewall-cmd --direct --get-all-rules | grep $NET_BRIDGE"
else
  if command -v nft >/dev/null 2>&1; then
    run "${SUDO} nft delete table inet agentvm_sandbox >/dev/null 2>&1 || true"
  fi
fi

# Remove local artifacts
run "${SUDO} rm -f '${BASE_DIR}/${VM_NAME}.ip' '${IMG_DIR}/${VM_NAME}.qcow2' '${CI_DIR}/${VM_NAME}-seed.iso' || true"

info "Done."
"""

README_MD = r"""# Agent VM plan

This directory contains a generated `.env` and step-by-step scripts.

## Workflow

### 1) Review and edit `.env`
Key knobs:
- `VM_NAME`, `VM_USER`, `VM_CPUS`, `VM_RAM_MB`, `VM_DISK_GB`
- `NET_NAME`, `NET_SUBNET_CIDR` (must not overlap host routes)
- `SSH_IDENTITY_FILE` + `SSH_PUBKEY_PATH` (cloud-init user key)
- `FIREWALL_BACKEND` (nft or firewalld)
- `ENABLE_FIREWALL` (set to 0 to skip the firewall isolation step)
- `ALLOW_PASSWORD_LOGIN` and `VM_PASSWORD` (SSH password login; less secure)
- `ENABLE_SHARE_PATHS` + `HOST_SHARE_SRC` (optional host directory sharing via virtiofs; breaks isolation)
- `ENABLE_PROVISION` (optional: install Docker and dev tools inside the VM)
- `BASE_IMG_PATH` (cached Ubuntu cloud base image path)
- `REDOWNLOAD_BASE_IMAGE` (set to 1 to force a fresh download)

### 2) Apply step-by-step (recommended the first time)
From this directory:

```bash
bash scripts/10_host_deps.sh
bash scripts/15_download_image.sh
bash scripts/20_network.sh
# Optional but recommended for isolation:
bash scripts/30_firewall.sh
bash scripts/40_vm.sh
bash scripts/50_print.sh
```

### 3) Or apply via the Python driver

```bash
python3 setup_agent_vm.py apply --outdir ./agentvm_plan --interactive
```

### 4) Cleanup

```bash
bash scripts/90_destroy.sh
```

## Security model

* VM is a KVM guest with no host folder sharing configured.
* Optional host firewall rules are scoped to the sandbox bridge (virbr-<NET_NAME>) to:

  * allow DHCP/DNS to the libvirt gateway only
  * block VM -> RFC1918 / local ranges (prevents reaching your LAN / host-adjacent services)

"""

SCRIPTS = {
    "00_common.sh": COMMON_SH,
    "10_host_deps.sh": HOST_DEPS_SH,
    "15_download_image.sh": DOWNLOAD_SH,
    "20_network.sh": NETWORK_SH,
    "30_firewall.sh": FIREWALL_SH,
    "40_vm.sh": VM_SH,
    "41_share_paths.sh": SHARE_PATHS_SH,
    "50_print.sh": PRINT_SH,
    "60_provision.sh": PROVISION_SH,
    "90_destroy.sh": DESTROY_SH,
}

SCRIPT_DOCS: Dict[str, str] = {
    "00_common.sh": textwrap.dedent("""
        Common helpers used by all scripts.

        Loads the plan .env file, defines consistent logging helpers, and provides
        safe shell utilities used throughout the workflow (including DRY_RUN support
        and apt_ensure for Debian and Ubuntu).
    """).strip(),

    "10_host_deps.sh": textwrap.dedent("""
        Ensure host dependencies are installed (Debian and Ubuntu).

        Uses apt_ensure to only install packages that are missing, so running this step
        on a machine that already has dependencies does not require sudo and does not
        modify the system. When installs are needed, it will use sudo, optionally run
        apt-get update (if UPDATE=1), and then enable and start libvirtd.
    """).strip(),

    "15_download_image.sh": textwrap.dedent("""
        Download and cache the Ubuntu 24.04 cloud image.

        Fetches the Ubuntu cloud image from UBUNTU_IMG_URL into BASE_IMG_PATH. If the
        file already exists, this step does nothing. Set REDOWNLOAD_BASE_IMAGE=1 to
        force a fresh download.
    """).strip(),

    "20_network.sh": textwrap.dedent("""
        Create a dedicated libvirt NAT network for the agent VM.

        Defines and starts a libvirt NAT network using NET_SUBNET_CIDR and a dedicated
        bridge virbr-<NET_NAME>. This avoids conflicts with existing host network
        customization such as bridges, VPN routes, Docker networks, or non-default
        libvirt networks.

        Safety behavior: refuses to proceed if a libvirt network with the same name
        already exists unless RECREATE=1.
    """).strip(),

    "30_firewall.sh": textwrap.dedent("""
        Optional isolation firewall rules scoped to the sandbox bridge.

        The goal is to let the VM reach the internet for apt, git, and pip while
        preventing it from reaching your host and local networks. Rules are scoped to
        the sandbox bridge virbr-<NET_NAME> to reduce risk of interfering with other
        host networking setups.

        Set ENABLE_FIREWALL=0 in .env to skip this step. Supports nftables or firewalld
        based on FIREWALL_BACKEND.
    """).strip(),

    "40_vm.sh": textwrap.dedent("""
        Provision the Ubuntu 24.04 agent VM via cloud-init.

        Uses the cached Ubuntu 24.04 cloud image at BASE_IMG_PATH, creates a qcow2
        overlay disk, generates a cloud-init seed that creates VM_USER and installs
        baseline tooling (ssh, git, python, and build tools), then defines and starts
        the VM.

        After boot, the script waits for the VM to receive a DHCP lease and records
        the discovered IP in BASE_DIR/<VM_NAME>.ip for later steps and for VS Code
        Remote-SSH.

        Paths:
          * BASE_DIR: top-level working directory for agent VM artifacts on the host
          * IMG_DIR: VM disk assets, including the cached base image and qcow2 overlay
          * CI_DIR: cloud-init artifacts and seed ISO for first boot
    """).strip(),

    "50_print.sh": textwrap.dedent("""
        Print connection and rollback instructions.

        Shows how to connect via SSH, provides a ready-to-copy ssh config stanza for
        VS Code Remote-SSH, and prints rollback commands to remove the VM, network,
        and firewall rules.
    """).strip(),


    "41_share_paths.sh": textwrap.dedent("""
        Share a host directory into the VM via virtiofs (optional).

        This step modifies the VM definition to add a virtiofs filesystem device that exports
        HOST_SHARE_SRC from the host into the guest under the tag HOST_SHARE_TAG. This is an
        intentional break in the default isolation model: the VM can read and write everything
        in the exported directory tree.

        After running this step, reboot the VM if needed, then mount inside the VM with:
          sudo mount -t virtiofs -o HOST_SHARE_MOUNT_OPTS HOST_SHARE_TAG HOST_SHARE_MOUNT
    """).strip(),

    "60_provision.sh": textwrap.dedent("""
        Provision developer tools inside the VM (optional).

        Uses SSH to connect to the VM and installs common developer tools and Docker using
        Ubuntu packages. This is a convenience step after the VM is reachable.
    """).strip(),
"90_destroy.sh": textwrap.dedent("""
        Best-effort cleanup of the agent VM environment.

        Destroys and undefines the VM, removes the libvirt NAT network, removes nftables
        isolation rules (when used), and deletes local plan artifacts.
    """).strip(),
}


def inject_doc(script_name: str, content: str) -> str:
    """Inject __doc__ plus --help handler into bash scripts for readability."""
    doc = SCRIPT_DOCS.get(script_name, "").strip()
    if not doc:
        return content

    if "'" in doc:
        raise ValueError(
            f"SCRIPT_DOCS contains a single quote character for {script_name}. "
            "Please remove or replace it."
        )

    lines = content.splitlines()
    if not lines or not lines[0].startswith("#!"):
        return content

    inject = [
        "__doc__='",
        doc,
        "'",
        'if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then echo "$__doc__"; exit 0; fi',
        "",
    ]
    return "\n".join([lines[0], *inject, *lines[1:]]) + "\n"

# ----------------------------- Plan writing -----------------------------


def write_plan_files(plan: Plan) -> None:
    ensure_dir(plan.outdir)
    ensure_dir(plan.outdir / "scripts")

    write_text(plan.outdir / ".env", env_file_contents(plan.env), 0o600)

    for name, content in SCRIPTS.items():
        write_text(plan.outdir / "scripts" / name, inject_doc(name, content), 0o755)

    write_text(plan.outdir / "README.md", README_MD, 0o644)


def print_plan_summary(plan: Plan) -> None:
    print("\nPlan summary")
    print("------------")

    def show(title: str, keys: List[str]) -> None:
        print(f"\n{title}")
        print("-" * len(title))
        for k in keys:
            print(f"{k:18} {plan.env.get(k, '')}")

    show("VM", ["VM_NAME", "VM_USER", "VM_CPUS", "VM_RAM_MB", "VM_DISK_GB"])
    show("Network", ["NET_NAME", "NET_SUBNET_CIDR", "NET_GATEWAY_IP", "DHCP_START", "DHCP_END"])
    show("Image", ["UBUNTU_IMG_URL", "BASE_IMG_PATH", "REDOWNLOAD_BASE_IMAGE"])
    show("Access", ["SSH_IDENTITY_FILE", "SSH_PUBKEY_PATH"])
    show("Firewall", ["FIREWALL_BACKEND", "ENABLE_FIREWALL"])

    print(f"\nOutput dir        {plan.outdir}")

    if plan.notes:
        print("\nNotes")
        print("-----")
        for n in plan.notes:
            print(f"- {n}")

# ----------------------------- Apply driver -----------------------------


def interactive_confirm(prompt: str, yes: bool) -> None:
    if yes:
        print(f"{prompt} [auto-yes]")
    return
    ans = input(f"{prompt} [y/N] ").strip().lower()
    if ans not in ("y", "yes"):
        raise SystemExit("Stopped by user.")


def apply_plan(outdir: Path, interactive: bool, yes: bool, no_firewall: bool) -> None:
    scripts_dir = outdir / "scripts"
    env_path = outdir / ".env"
    if not scripts_dir.exists() or not env_path.exists():
        raise SystemExit(f"Missing plan at: {outdir}. Run: python3 setup_agent_vm.py plan --outdir {outdir}")

    # Respect optional steps based on .env and flags
    env_vars = parse_env_file(env_path)
    enable_firewall = str(env_vars.get("ENABLE_FIREWALL", "1")).strip() == "1"
    if no_firewall:
        enable_firewall = False

    scripts_in_order: List[str] = [
        "10_host_deps.sh",
        "15_download_image.sh",
        "20_network.sh",
    ]
    if enable_firewall:
        scripts_in_order.append("30_firewall.sh")
    else:
        print("Skipping firewall step (ENABLE_FIREWALL=0 or --no-firewall).")
    scripts_in_order.append("40_vm.sh")

    enable_share = str(env_vars.get("ENABLE_SHARE_PATHS", "0")).strip() == "1"
    if enable_share:
        scripts_in_order.append("41_share_paths.sh")
    else:
        print("Skipping share paths step (ENABLE_SHARE_PATHS=0).")

    scripts_in_order.append("50_print.sh")

    enable_provision = str(env_vars.get("ENABLE_PROVISION", "0")).strip() == "1"
    if enable_provision:
        scripts_in_order.append("60_provision.sh")
    else:
        print("Skipping provision step (ENABLE_PROVISION=0).")


    # Optional interactive checkpoint
    if interactive and not yes:
        print("\nScripts to run in order:")
        for sname in scripts_in_order:
            print(f"  - {sname}")
        ans = input("\nProceed? [y/N] ").strip().lower()
        if ans not in {"y", "yes"}:
            raise SystemExit(1)

    for script_name in scripts_in_order:
        script_path = scripts_dir / script_name
        print(f"\n=== Running {script_name} ===")
        p = subprocess.run(["bash", str(script_path)], cwd=str(outdir))
        if p.returncode != 0:
            raise SystemExit(p.returncode)


def clean_plan(outdir: Path) -> None:
    if outdir.exists():
        shutil.rmtree(outdir)
        print(f"Removed {outdir}")
    else:
        print(f"Nothing to remove at {outdir}")

# ----------------------------- CLI -----------------------------


def main(argv: List[str]) -> int:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    ap_plan = sub.add_parser("plan", help="Write .env + scripts to disk")
    ap_plan.add_argument("--outdir", default="agentvm_plan", help="Output directory")
    ap_plan.add_argument("--env-in", default=None, help="Optional .env file to use as defaults/overrides when writing the plan")
    ap_plan.add_argument("--set", action="append", default=[], help="Override a single env var (KEY=VALUE). Can be used multiple times.")

    ap_apply = sub.add_parser("apply", help="Execute generated scripts (they will sudo as needed)")
    ap_apply.add_argument("--outdir", default="agentvm_plan", help="Plan directory")
    ap_apply.add_argument("--interactive", action="store_true", help="Prompt before each script")
    ap_apply.add_argument("--yes", action="store_true", help="Assume yes to prompts")
    ap_apply.add_argument("--no-firewall", action="store_true", help="Skip the firewall step (equivalent to ENABLE_FIREWALL=0)")

    ap_clean = sub.add_parser("clean", help="Remove plan directory")
    ap_clean.add_argument("--outdir", default="agentvm_plan", help="Plan directory")

    args = ap.parse_args(argv)

    outdir = Path(args.outdir).resolve()

    if args.cmd == "plan":
        plan = build_plan(outdir)

        # Apply overrides from existing .env files
        override_paths: List[Path] = []

        local_env = Path(__file__).resolve().parent / ".env"
        if local_env.exists():
            LOGGER.info("Loading overrides from local .env: %s", local_env)
            override_paths.append(local_env)

        if args.env_in:
            p = Path(args.env_in).expanduser().resolve()
            if not p.exists():
                raise SystemExit(f"--env-in file does not exist: {p}")
            LOGGER.info("Loading overrides from --env-in: %s", p)
            override_paths.append(p)

        existing_plan_env = outdir / ".env"
        if existing_plan_env.exists():
            LOGGER.info("Loading overrides from existing plan .env: %s", existing_plan_env)
            override_paths.append(existing_plan_env)

        for p in override_paths:
            plan.env = apply_overrides(plan.env, parse_env_file(p))

        if args.set:
            LOGGER.info("Applying %d --set overrides", len(args.set))
            plan.env = apply_kv_overrides(plan.env, args.set)

        plan.env = fill_derived_env(plan.env, plan.notes)

        write_plan_files(plan)
        print_plan_summary(plan)

        print("\nREADME.md")
        print("---------")
        print((outdir / "README.md").read_text())

        print(f"Plan written to: {outdir}")
        print(textwrap.dedent(
            f'''
            If .env is setup correctly you can inspect and run the following
            commands to understand the process.

            bash {outdir}/scripts/10_host_deps.sh
            bash {outdir}/scripts/15_download_image.sh
            bash {outdir}/scripts/20_network.sh
            # Optional but recommended for isolation:
            bash {outdir}/scripts/30_firewall.sh
            bash {outdir}/scripts/40_vm.sh
            # Optional: share a host directory into the VM (breaks default isolation model)
            bash {outdir}/scripts/41_share_paths.sh
            bash {outdir}/scripts/50_print.sh
            # Optional: install docker and developer tools inside the VM
            bash {outdir}/scripts/60_provision.sh
            '''))
        print("To run everything use:")
        print(f"Next: python3 setup_agent_vm.py apply --outdir {outdir} --interactive")
        return 0

    if args.cmd == "apply":
        apply_plan(outdir, interactive=args.interactive, yes=args.yes, no_firewall=args.no_firewall)
        return 0

    if args.cmd == "clean":
        clean_plan(outdir)
        return 0

    return 1

if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
