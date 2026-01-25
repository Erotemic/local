#!/usr/bin/env bash
# setup_windows_vm.sh
set -euo pipefail

__doc__='
setup_windows_vm.sh

Headless-ish Windows 11 VM provisioning on KVM/libvirt using virt-install.
- Uses libvirt NAT by default (does NOT modify host networking)
- Binds VNC to localhost (access via SSH tunnel)
- Uses UEFI + TPM2 (good for Windows 11)
- Attaches VirtIO driver ISO so Windows can install onto VirtIO disk/NIC (fast virtual devices)

Prereq ISOs (Windows 11 + VirtIO drivers):

  1) Windows 11 installation ISO (official Microsoft download page):
       https://www.microsoft.com/software-download/windows11

  2) VirtIO driver ISO (KVM/Windows drivers):
       https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
     Browse directory (checksums / variants):
       https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/

Suggested ISO placement:
  Create /opt/vm/isos and move ISOs from ~/Downloads:
    sudo mkdir -p /opt/vm/isos
    sudo mv ~/Downloads/Win11_25H2_English_x64.iso /opt/vm/isos/Win11_25H2_English_x64.iso
    sudo mv ~/Downloads/virtio-win-0.1.285.iso /opt/vm/isos/virtio-win-0.1.285.iso
    ls -lh /opt/vm/isos

Usage:
  # Run everything (deps + checks + create VM)
  WIN_ISO=/opt/vm/isos/Win11_25H2_English_x64.iso \
  VIRTIO_ISO=/opt/vm/isos/virtio-win-0.1.285.iso \
  ./setup_windows_vm.sh all

Override config with env vars:
  VM_NAME=win11 \
  VM_DISK_GB=200 \
  WIN_ISO=/opt/vm/isos/Win11_25H2_English_x64.iso \
  VIRTIO_ISO=/opt/vm/isos/virtio-win-0.1.285.iso \
  ./setup_windows_vm.sh

Modes:

  export VM_NAME=win11
  export VM_DISK_GB=200
  export WIN_ISO=/opt/vm/isos/Win11_25H2_English_x64.iso
  export VIRTIO_ISO=/opt/vm/isos/virtio-win-0.1.285.iso

  ./setup_windows_vm.sh prereq     # install deps + start services + group membership
  ./setup_windows_vm.sh check      # validate config and environment (no changes)
  ./setup_windows_vm.sh create     # create VM only
  ./setup_windows_vm.sh all        # prereq + check + create

Dry-run:
  ./setup_windows_vm.sh --dry-run all
  (prints what it would do; does not modify the system)

Install notes (inside Windows Setup):
  - If no disks appear, click "Load driver", browse the VirtIO CD, and select the storage driver.
      THIS IS IN THE E:/amd64/w11 folder
  - It will ask for a network driver on startup, you can also give it the
    VirtIO cd to help it find that.
  - After Windows boots, run the VirtIO installer from the VirtIO CD for best performance.


Working with the VM after creation

List all VMs (running + stopped):
  sudo virsh -c qemu:///system list --all

Check a specific VM state:
  sudo virsh -c qemu:///system domstate win11
  sudo virsh -c qemu:///system dominfo  win11

Start / shutdown / force-off:
  sudo virsh -c qemu:///system start    win11
  sudo virsh -c qemu:///system shutdown win11
  sudo virsh -c qemu:///system destroy  win11   # hard power-off (last resort)

Autostart at boot:
  sudo virsh -c qemu:///system autostart win11

Connect with virt-manager (GUI) from the host:
  # Install virt-manager if needed:
  sudo apt-get install -y virt-manager
  # Then run:
  virt-manager
  # Connect to: qemu:///system
  # Select VM "win11" and open console

Headless-console access via VNC (recommended for install; safe because it binds to localhost):
  # Get the VNC display:
  sudo virsh -c qemu:///system vncdisplay win11
    -> prints something like :1
  # Convert :N to TCP port 5900+N (e.g. :1 => 5901)

  # If you are on a different machine, tunnel it over SSH:
  ssh -L 5901:127.0.0.1:5901 <user>@<host-running-libvirt>
  # Then connect your VNC viewer to:
  localhost:5901

Alternatively, open the display URI (works locally):
  sudo virsh -c qemu:///system domdisplay win11

Find VM IP address (works best if qemu guest agent is installed in Windows):
  sudo virsh -c qemu:///system domifaddr win11

If using the default libvirt NAT network, you can also see DHCP leases:
  sudo virsh -c qemu:///system net-dhcp-leases default

'


############################################
# Configurable environment variables
############################################

# Behavior
ACTION="${ACTION:-all}"                 # prereq|check|create|all
DRY_RUN="${DRY_RUN:-0}"                 # 1 = print only, no changes
CONNECT_URI="${CONNECT_URI:-qemu:///system}"
AUTOSTART="${AUTOSTART:-1}"             # autostart VM at boot if created

# VM identity / sizing
VM_NAME="${VM_NAME:-win11}"
VM_RAM_MB="${VM_RAM_MB:-8192}"
VM_VCPUS="${VM_VCPUS:-4}"
VM_DISK_GB="${VM_DISK_GB:-200}"

# Storage
STORAGE_DIR="${STORAGE_DIR:-/opt/vm/libvirt/images}"
DISK_PATH="${DISK_PATH:-${STORAGE_DIR}/${VM_NAME}.qcow2}"
DISK_FORMAT="${DISK_FORMAT:-qcow2}"

# Install media
WIN_ISO="${WIN_ISO:-}"
VIRTIO_ISO="${VIRTIO_ISO:-}"

# VM hardware / OS
MACHINE_TYPE="${MACHINE_TYPE:-q35}"
CPU_MODE="${CPU_MODE:-host-passthrough}"
UEFI="${UEFI:-1}"
TPM2="${TPM2:-1}"
VIDEO_MODEL="${VIDEO_MODEL:-virtio}"

# virt-install osinfo toggles (normalize to what virt-install expects)
# Your virt-install complained detect must be 'yes' or 'no', so we normalize that way.
OSINFO_DETECT="${OSINFO_DETECT:-yes}"     # yes/no (accepts on/off too)
OSINFO_REQUIRE="${OSINFO_REQUIRE:-off}"   # on/off (accepts yes/no too)

# Networking (NAT by default; does not touch host networking)
LIBVIRT_NET="${LIBVIRT_NET:-default}"
NET_MODEL="${NET_MODEL:-virtio}"

# Headless console
GRAPHICS_TYPE="${GRAPHICS_TYPE:-vnc}"     # vnc or spice
GRAPHICS_LISTEN="${GRAPHICS_LISTEN:-127.0.0.1}"
GRAPHICS_PORT="${GRAPHICS_PORT:--1}"      # -1 auto

# Advanced extra args (space-separated; use with care)
EXTRA_VIRT_INSTALL_ARGS="${EXTRA_VIRT_INSTALL_ARGS:-}"

############################################
# Helpers
############################################

log()  { printf "\n==> %s\n" "$*" >&2; }
warn() { printf "\n[WARN] %s\n" "$*" >&2; }
die()  { printf "\n[ERROR] %s\n" "$*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

run() {
  # Print command; execute unless dry-run
  echo "+ $*" >&2
  if [[ "$DRY_RUN" == "1" ]]; then return 0; fi
  "$@"
}

as_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    run "$@"
  else
    run sudo "$@"
  fi
}

virshc() {
  # Always use a consistent libvirt URI to avoid session/system confusion
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    run virsh -c "$CONNECT_URI" "$@"
  else
    run sudo virsh -c "$CONNECT_URI" "$@"
  fi
}

normalize_yesno() {
  # Normalize to yes/no (accept on/off/true/false/1/0)
  local v="${1,,}"
  case "$v" in
    yes|y|true|1|on)  echo yes ;;
    no|n|false|0|off) echo no ;;
    *) die "Invalid value '$1' (expected yes/no/on/off/true/false/1/0)" ;;
  esac
}

normalize_onoff() {
  # Normalize to on/off (accept yes/no/true/false/1/0)
  local v="${1,,}"
  case "$v" in
    on|true|1|yes|y)  echo on ;;
    off|false|0|no|n) echo off ;;
    *) die "Invalid value '$1' (expected on/off/yes/no/true/false/1/0)" ;;
  esac
}

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then echo apt
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v yum >/dev/null 2>&1; then echo yum
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  else echo unknown
  fi
}

install_deps() {
  local mgr; mgr="$(detect_pkg_mgr)"
  log "Installing dependencies (pkg manager: $mgr)"

  case "$mgr" in
    apt)
      as_root apt-get update -y
      as_root apt-get install -y \
        qemu-kvm qemu-utils \
        libvirt-daemon-system libvirt-clients \
        virtinst ovmf swtpm dnsmasq-base
      ;;
    dnf)
      as_root dnf install -y \
        @virtualization virt-install edk2-ovmf swtpm qemu-img dnsmasq
      ;;
    yum)
      as_root yum install -y \
        virt-install libvirt libvirt-client \
        qemu-kvm qemu-img edk2-ovmf swtpm dnsmasq
      ;;
    pacman)
      as_root pacman -Sy --noconfirm \
        qemu-full libvirt virt-install edk2-ovmf swtpm dnsmasq
      ;;
    *)
      warn "Unknown package manager. Install manually: qemu-kvm, libvirt, virt-install, ovmf/edk2-ovmf, swtpm, qemu-img."
      ;;
  esac
}

start_libvirt_services() {
  log "Ensuring libvirt services are running"

  # Try common service/unit names across distros/libvirt versions
  local units=(
    libvirtd.service
    libvirtd.socket
    virtqemud.service
    virtqemud.socket
    virtnetworkd.service
    virtnetworkd.socket
  )

  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not found; skipping service management. Ensure libvirt is running."
    return 0
  fi

  local any_found=0
  for u in "${units[@]}"; do
    if systemctl list-unit-files | grep -q "^${u}"; then
      any_found=1
      # enabling a socket is often enough; enabling a service is fine too
      as_root systemctl enable --now "$u" || true
    fi
  done

  if [[ "$any_found" == "0" ]]; then
    warn "Could not find libvirt systemd units. Ensure libvirt is installed/running."
  fi

  # Verify connectivity
  if [[ "$DRY_RUN" != "1" ]]; then
    if ! sudo virsh -c "$CONNECT_URI" uri >/dev/null 2>&1; then
      warn "virsh cannot connect to $CONNECT_URI yet."
      warn "Try: sudo systemctl status libvirtd virtqemud virtnetworkd --no-pager"
    fi
  fi
}

ensure_groups() {
  local user="${SUDO_USER:-$USER}"
  log "Ensuring user is in libvirt/kvm groups (user: $user)"
  if getent group libvirt >/dev/null 2>&1; then as_root usermod -aG libvirt "$user" || true; fi
  if getent group kvm     >/dev/null 2>&1; then as_root usermod -aG kvm     "$user" || true; fi
  warn "Group changes may require re-login to take effect."
}

validate_inputs() {
  [[ -n "$WIN_ISO" ]] || die "WIN_ISO is required (path to Windows 11 ISO)."
  [[ -f "$WIN_ISO" ]] || die "WIN_ISO not found: $WIN_ISO"

  if [[ -n "$VIRTIO_ISO" ]]; then
    [[ -f "$VIRTIO_ISO" ]] || die "VIRTIO_ISO not found: $VIRTIO_ISO"
  else
    warn "VIRTIO_ISO not set. Windows installer may not see virtio disk/NIC without drivers."
  fi
}

ensure_storage() {
  log "Ensuring storage directory exists: $STORAGE_DIR"
  as_root mkdir -p "$STORAGE_DIR"
  as_root chmod 0755 "$STORAGE_DIR"

  if [[ ! -f "$DISK_PATH" ]]; then
    log "Creating disk image: $DISK_PATH (${VM_DISK_GB}G, ${DISK_FORMAT})"
    as_root qemu-img create -f "$DISK_FORMAT" "$DISK_PATH" "${VM_DISK_GB}G"
  else
    log "Disk already exists: $DISK_PATH (not modifying)"
  fi
}

ensure_libvirt_net() {
  log "Checking libvirt network: $LIBVIRT_NET"
  if ! sudo virsh -c "$CONNECT_URI" net-info "$LIBVIRT_NET" >/dev/null 2>&1; then
    die "Libvirt network '$LIBVIRT_NET' not found. Try 'default' (NAT) or create your own."
  fi

  local state
  state="$(sudo virsh -c "$CONNECT_URI" net-info "$LIBVIRT_NET" | awk -F: '/Active/ {gsub(/ /,"",$2); print $2}')"
  if [[ "$state" != "yes" ]]; then
    log "Starting libvirt network: $LIBVIRT_NET"
    virshc net-start "$LIBVIRT_NET"
  fi
  virshc net-autostart "$LIBVIRT_NET" >/dev/null 2>&1 || true
}

vm_exists() {
  sudo virsh -c "$CONNECT_URI" dominfo "$VM_NAME" >/dev/null 2>&1
}

build_virt_install_args() {
  # Build args as an array to avoid quoting/word-splitting issues.
  VIRT_ARGS=()

  local detect_yesno require_onoff
  detect_yesno="$(normalize_yesno "$OSINFO_DETECT")"
  require_onoff="$(normalize_onoff "$OSINFO_REQUIRE")"

  VIRT_ARGS+=(--connect "$CONNECT_URI")
  VIRT_ARGS+=(--name "$VM_NAME")
  VIRT_ARGS+=(--memory "$VM_RAM_MB")
  VIRT_ARGS+=(--vcpus "$VM_VCPUS")
  VIRT_ARGS+=(--cpu "$CPU_MODE")
  VIRT_ARGS+=(--machine "$MACHINE_TYPE")
  # NOTE: we emit detect=yes|no because your virt-install requires it.
  VIRT_ARGS+=(--osinfo "detect=${detect_yesno},require=${require_onoff}")

  if [[ "$UEFI" == "1" ]]; then
    VIRT_ARGS+=(--boot uefi)
  fi

  if [[ "$TPM2" == "1" ]]; then
    VIRT_ARGS+=(--tpm "backend.type=emulator,backend.version=2.0,model=tpm-tis")
  fi

  VIRT_ARGS+=(--disk "path=${DISK_PATH},format=${DISK_FORMAT},bus=virtio,cache=none,discard=unmap")
  VIRT_ARGS+=(--cdrom "$WIN_ISO")

  if [[ -n "$VIRTIO_ISO" ]]; then
    VIRT_ARGS+=(--disk "path=${VIRTIO_ISO},device=cdrom")
  fi

  VIRT_ARGS+=(--network "network=${LIBVIRT_NET},model=${NET_MODEL}")
  VIRT_ARGS+=(--graphics "${GRAPHICS_TYPE},listen=${GRAPHICS_LISTEN},port=${GRAPHICS_PORT}")
  VIRT_ARGS+=(--sound none)
  VIRT_ARGS+=(--video "$VIDEO_MODEL")
  VIRT_ARGS+=(--noautoconsole)

  if [[ -n "$EXTRA_VIRT_INSTALL_ARGS" ]]; then
    # shellcheck disable=SC2206
    local extra_arr=($EXTRA_VIRT_INSTALL_ARGS)
    VIRT_ARGS+=("${extra_arr[@]}")
  fi
}

create_vm() {
  if vm_exists; then
    log "VM already exists: $VM_NAME (not recreating)"
    return 0
  fi

  log "Creating VM: $VM_NAME"
  build_virt_install_args

  echo "+ virt-install ${VIRT_ARGS[*]}" >&2
  if [[ "$DRY_RUN" == "1" ]]; then return 0; fi
  sudo virt-install "${VIRT_ARGS[@]}"

  if [[ "$AUTOSTART" == "1" ]]; then
    virshc autostart "$VM_NAME" >/dev/null 2>&1 || true
  fi
}

print_access_info() {
  if ! vm_exists; then
    warn "VM '$VM_NAME' does not exist (yet). Skipping dominfo/display."
    return 0
  fi

  log "VM summary"
  sudo virsh -c "$CONNECT_URI" dominfo "$VM_NAME" || true
  echo

  log "VNC display (if applicable)"
  if sudo virsh -c "$CONNECT_URI" vncdisplay "$VM_NAME" >/dev/null 2>&1; then
    local disp; disp="$(sudo virsh -c "$CONNECT_URI" vncdisplay "$VM_NAME" | tr -d '\r')"
    echo "virsh vncdisplay: ${disp}"
    if [[ "$disp" =~ ^:([0-9]+)$ ]]; then
      local n="${BASH_REMATCH[1]}"
      local port=$((5900 + n))
      echo
      echo "Connect via SSH tunnel from your client machine:"
      echo "  ssh -L ${port}:${GRAPHICS_LISTEN}:${port} <user>@<host>"
      echo "Then open your VNC viewer to: localhost:${port}"
    else
      echo "If this isn't :N form, use: sudo virsh -c ${CONNECT_URI} domdisplay ${VM_NAME}"
    fi
  else
    echo "No VNC display reported. Try: sudo virsh -c ${CONNECT_URI} domdisplay ${VM_NAME}"
  fi
}

on_err() {
  local rc=$?
  warn "Failed (exit code $rc). Helpful recovery commands:"
  warn "  sudo virsh -c ${CONNECT_URI} list --all | sed -n '1,5p;/${VM_NAME}/p'"
  warn "  sudo virsh -c ${CONNECT_URI} dominfo ${VM_NAME} || true"
  warn "  sudo virsh -c ${CONNECT_URI} dumpxml ${VM_NAME} | head -n 80 || true"
  warn "  sudo journalctl -u libvirtd -u virtqemud -u virtnetworkd -n 200 --no-pager || true"
  warn "  ls -lh ${DISK_PATH} || true"
  exit "$rc"
}
trap on_err ERR

usage() { echo "$__doc__"; }

parse_args() {
  local positional=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      prereq|check|create|all) ACTION="$1"; shift ;;
      -n|--dry-run) DRY_RUN=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) positional+=("$1"); shift ;;
    esac
  done
  if [[ ${#positional[@]} -gt 0 ]]; then
    warn "Ignoring unexpected args: ${positional[*]}"
  fi
}

do_prereq() {
  install_deps
  start_libvirt_services
  ensure_groups
}

do_check() {
  # No changes unless DRY_RUN=0, but check tries to be non-invasive either way.
  need_cmd sudo
  need_cmd virsh || true
  need_cmd virt-install || true
  need_cmd qemu-img || true

  # Validate toggles early
  normalize_yesno "$OSINFO_DETECT" >/dev/null
  normalize_onoff "$OSINFO_REQUIRE" >/dev/null

  validate_inputs
  # Connectivity + libvirt network checks (can fail usefully)
  if [[ "$DRY_RUN" != "1" ]]; then
    sudo virsh -c "$CONNECT_URI" uri >/dev/null 2>&1 || warn "virsh cannot connect to $CONNECT_URI"
  fi
  ensure_libvirt_net

  echo
  log "Config looks OK (basic checks passed)."
  echo "  VM_NAME=${VM_NAME}"
  echo "  DISK_PATH=${DISK_PATH}"
  echo "  WIN_ISO=${WIN_ISO}"
  echo "  VIRTIO_ISO=${VIRTIO_ISO:-<unset>}"
}

do_create() {
  validate_inputs
  ensure_storage
  ensure_libvirt_net
  create_vm

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Dry-run: skipping VM queries (dominfo/vncdisplay)."
    return 0
  fi

  print_access_info
}


main() {
  parse_args "$@"

  case "$ACTION" in
    prereq)
      do_prereq
      ;;
    check)
      do_check
      ;;
    create)
      do_create
      ;;
    all)
      do_prereq
      do_check
      do_create
      ;;
    *)
      die "Unknown action: $ACTION (expected prereq|check|create|all)"
      ;;
  esac

  log "Done."
}

main "$@"
