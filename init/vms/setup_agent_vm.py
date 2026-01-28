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
import ipaddress
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple


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

        # Paths (review before apply if you prefer different locations)
        "BASE_DIR": "/var/lib/libvirt/agentvm",
        "IMG_DIR": "/var/lib/libvirt/agentvm/images",
        "CI_DIR": "/var/lib/libvirt/agentvm/cloud-init",

        # SSH identity (private key); scripts will use SSH_PUBKEY_PATH for cloud-init
        "SSH_IDENTITY_FILE": ssh_identity,
        "SSH_PUBKEY_PATH": pub_guess,

        # Firewall backend
        "FIREWALL_BACKEND": firewall_backend,

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
    if target.overlaps(n) and str(n) != str(target):
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

: "${NET_NAME:?NET_NAME missing}"
: "${NET_GATEWAY_IP:?NET_GATEWAY_IP missing}"
: "${FIREWALL_BACKEND:?FIREWALL_BACKEND missing}"

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

  run "${SUDO} nft list table inet agentvm_sandbox >/dev/null 2>&1 || nft add table inet agentvm_sandbox"
  run "${SUDO} bash -lc 'if nft list chain inet agentvm_sandbox forward >/dev/null 2>&1; then nft flush chain inet agentvm_sandbox forward; else nft add chain inet agentvm_sandbox forward \"{ type filter hook forward priority 0; policy accept; }\"; fi'"

  # Allow DHCP + DNS to gateway
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip protocol udp udp dport {67,68} accept"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP udp dport 53 accept"
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP tcp dport 53 accept"
  # Block other gateway access
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr $NET_GATEWAY_IP drop"
  # Block private/local ranges
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip daddr {10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16,127.0.0.0/8} drop"
  # Best-effort IPv6 local blocks
  run "${SUDO} nft add rule inet agentvm_sandbox forward iifname \"$NET_BRIDGE\" ip6 daddr {fd00::/8,fe80::/10,::1/128} drop 2>/dev/null || true"

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

require_cmd curl
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
: "${UBUNTU_IMG_URL:?UBUNTU_IMG_URL missing}"
: "${BASE_DIR:?BASE_DIR missing}"
: "${IMG_DIR:?IMG_DIR missing}"
: "${CI_DIR:?CI_DIR missing}"
: "${SSH_PUBKEY_PATH:?SSH_PUBKEY_PATH missing}"

# Ensure dirs (need root for /var/lib)
run "${SUDO} mkdir -p '$IMG_DIR' '$CI_DIR' '$BASE_DIR'"
run "${SUDO} chmod 700 '$BASE_DIR' '$CI_DIR' || true"

BASE_IMG="${IMG_DIR}/noble-base.img"
VM_DISK="${IMG_DIR}/${VM_NAME}.qcow2"
SEED_ISO="${CI_DIR}/${VM_NAME}-seed.iso"
USER_DATA="${CI_DIR}/user-data"
META_DATA="${CI_DIR}/meta-data"

# Validate SSH pubkey
if [[ ! -f "$SSH_PUBKEY_PATH" ]]; then
  die "Missing SSH public key at $SSH_PUBKEY_PATH. Ensure SSH_IDENTITY_FILE exists and SSH_PUBKEY_PATH is correct."
fi

# Download base image if needed
if [[ ! -f "$BASE_IMG" ]]; then
  info "Downloading Ubuntu cloud image..."
  run "${SUDO} curl -L --fail -o '$BASE_IMG' '$UBUNTU_IMG_URL'"
else
  info "Cloud image already present: $BASE_IMG"
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

# Write cloud-init
PUBKEY_CONTENT="$(cat "$SSH_PUBKEY_PATH")"
run "${SUDO} bash -lc 'cat > \"$USER_DATA\" <<EOF
#cloud-config
users:
  - name: ${VM_USER}
    groups: [sudo]
    shell: /bin/bash
    sudo: [\"ALL=(ALL) NOPASSWD:ALL\"]
    ssh_authorized_keys:
      - ${PUBKEY_CONTENT}

ssh_pwauth: false
disable_root: true

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
      PasswordAuthentication no
      PermitRootLogin no
      KbdInteractiveAuthentication no
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
IP=""
for _ in $(seq 1 60); do
  IP="$(${SUDO} virsh domifaddr '$VM_NAME' 2>/dev/null | awk '/ipv4/ {print $4}' | head -n1 | cut -d/ -f1 || true)"
  if [[ -n "$IP" ]]; then
    info "VM IP: $IP"
    run "${SUDO} bash -lc 'echo \"$IP\" > \"${BASE_DIR}/${VM_NAME}.ip\"'"
    exit 0
  fi
  sleep 2
done

warn "Timed out discovering VM IP."
warn "Try: ${SUDO} virsh net-dhcp-leases $NET_NAME"
exit 2
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

### 2) Apply step-by-step (recommended the first time)
From this directory:

```bash
bash scripts/10_host_deps.sh
bash scripts/20_network.sh
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
* Host firewall rules are scoped to the sandbox bridge (virbr-<NET_NAME>) to:

  * allow DHCP/DNS to the libvirt gateway only
  * block VM -> RFC1918 / local ranges (prevents reaching your LAN / host-adjacent services)
"""

SCRIPTS = {
    "00_common.sh": COMMON_SH,
    "10_host_deps.sh": HOST_DEPS_SH,
    "20_network.sh": NETWORK_SH,
    "30_firewall.sh": FIREWALL_SH,
    "40_vm.sh": VM_SH,
    "50_print.sh": PRINT_SH,
    "90_destroy.sh": DESTROY_SH,
}

# ----------------------------- Plan writing -----------------------------


def write_plan_files(plan: Plan) -> None:
    ensure_dir(plan.outdir)
    ensure_dir(plan.outdir / "scripts")

    write_text(plan.outdir / ".env", env_file_contents(plan.env), 0o600)

    for name, content in SCRIPTS.items():
        write_text(plan.outdir / "scripts" / name, content, 0o755)

    write_text(plan.outdir / "README.md", README_MD, 0o644)


def print_plan_summary(plan: Plan) -> None:
    print("\nPlan summary")
    print("------------")
    for k in ["VM_NAME", "VM_USER", "VM_CPUS", "VM_RAM_MB", "VM_DISK_GB"]:
        print(f"{k:16} {plan.env.get(k, '')}")
        print()
    for k in ["NET_NAME", "NET_SUBNET_CIDR", "NET_GATEWAY_IP", "DHCP_START", "DHCP_END"]:
        print(f"{k:16} {plan.env.get(k, '')}")
        print()
    for k in ["SSH_IDENTITY_FILE", "SSH_PUBKEY_PATH", "FIREWALL_BACKEND"]:
        print(f"{k:16} {plan.env.get(k, '')}")
        print()
        print(f"Output dir       {plan.outdir}")
        print()
    if plan.notes:
        print("Notes")
        print("-----")
    for n in plan.notes:
        print(f"- {n}")
        print()

# ----------------------------- Apply driver -----------------------------


def interactive_confirm(prompt: str, yes: bool) -> None:
    if yes:
        print(f"{prompt} [auto-yes]")
    return
    ans = input(f"{prompt} [y/N] ").strip().lower()
    if ans not in ("y", "yes"):
        raise SystemExit("Stopped by user.")


def apply_plan(outdir: Path, interactive: bool, yes: bool) -> None:
    scripts_dir = outdir / "scripts"
    env_path = outdir / ".env"
    if not scripts_dir.exists() or not env_path.exists():
        raise SystemExit(f"Missing plan files in {outdir}. Run: python3 setup_agent_vm.py plan --outdir {outdir}")

    scripts_in_order = [
        "10_host_deps.sh",
        "20_network.sh",
        "30_firewall.sh",
        "40_vm.sh",
        "50_print.sh",
    ]

    print(f"Applying plan in {outdir}")
    print("Scripts:")
    for s in scripts_in_order:
        print(f" - scripts/{s}")

    for s in scripts_in_order:
        if interactive:
            interactive_confirm(f"Run scripts/{s}?", yes=yes)
        script_path = scripts_dir / s
        # Run as current user; scripts will use sudo only when needed.
        # This keeps initial apply accessible but still safe.
        p = subprocess.run(["bash", str(script_path)], cwd=str(outdir))
        if p.returncode != 0:
            raise SystemExit(f"Failed at scripts/{s} (exit {p.returncode}). See output above.")


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

    ap_apply = sub.add_parser("apply", help="Execute generated scripts (they will sudo as needed)")
    ap_apply.add_argument("--outdir", default="agentvm_plan", help="Plan directory")
    ap_apply.add_argument("--interactive", action="store_true", help="Prompt before each script")
    ap_apply.add_argument("--yes", action="store_true", help="Assume yes to prompts")

    ap_clean = sub.add_parser("clean", help="Remove plan directory")
    ap_clean.add_argument("--outdir", default="agentvm_plan", help="Plan directory")

    args = ap.parse_args(argv)

    outdir = Path(args.outdir).resolve()

    if args.cmd == "plan":
        plan = build_plan(outdir)
        write_plan_files(plan)
        print_plan_summary(plan)
        print(f"Plan written to: {outdir}")
        print(f"Next: python3 setup_agent_vm.py apply --outdir {outdir} --interactive")
        return 0

    if args.cmd == "apply":
        apply_plan(outdir, interactive=args.interactive, yes=args.yes)
        return 0

    if args.cmd == "clean":
        clean_plan(outdir)
        return 0

    return 1

if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))


"""
---

## How to use

1) Save that as `setup_agent_vm.py` and run:

```bash
python3 setup_agent_vm.py plan
````

2. Review and edit:

```bash
sed -n '1,200p' agentvm_plan/.env
ls -la agentvm_plan/scripts
```

3. Apply carefully:

```bash
python3 setup_agent_vm.py apply --interactive
```

Or unattended:

```bash
python3 setup_agent_vm.py apply --yes
```

---

## Why this is safer / easier to audit

* **No sudo needed for plan** (just writes files and detects context).
* Install/download steps are **explicit scripts** you can read before running.
* `apt_ensure` avoids `sudo apt install` if everything is already installed.
* Isolation rules are scoped to the **sandbox bridge only**.

---

## Small but important follow-ups I’d recommend (optional)

* Add a `plan --refresh` mode that re-evaluates routes/firewall and updates `.env` without rewriting custom edits.
* Add a `--dry-run` apply option that exports `DRY_RUN=1` when running scripts (so you can rehearse what apply would do).

If you want, I can fold both of those in next.


"""
