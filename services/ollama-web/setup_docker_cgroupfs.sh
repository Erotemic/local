#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: sudo bash $0 [options]

Options:
  -h, --help             Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: run as root (use sudo)." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to safely edit /etc/docker/daemon.json" >&2
  exit 1
fi

DAEMON_JSON="/etc/docker/daemon.json"
DAEMON_DIR="$(dirname "$DAEMON_JSON")"
mkdir -p "$DAEMON_DIR"

timestamp="$(date +%Y%m%d-%H%M%S)"
if [[ -f "$DAEMON_JSON" ]]; then
  cp -a "$DAEMON_JSON" "${DAEMON_JSON}.bak.${timestamp}"
  echo "Backed up $DAEMON_JSON to ${DAEMON_JSON}.bak.${timestamp}"
fi

# Edit daemon.json idempotently: set native.cgroupdriver=cgroupfs and preserve other keys.
python3 - <<'PY'
import json, os
path="/etc/docker/daemon.json"

data={}
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path, "r", encoding="utf-8") as f:
        data=json.load(f)

opts=data.get("exec-opts", [])
if opts is None:
    opts=[]
if not isinstance(opts, list):
    raise SystemExit(f"exec-opts must be a list in {path}; found {type(opts).__name__}")

# remove existing cgroupdriver entry if any
opts=[o for o in opts if not (isinstance(o,str) and o.startswith("native.cgroupdriver="))]
opts.append("native.cgroupdriver=cgroupfs")
data["exec-opts"]=opts

tmp=path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, sort_keys=True)
    f.write("\n")
os.replace(tmp, path)
print(f"Wrote {path} with exec-opts={data['exec-opts']}")
PY

echo "Restarting Docker..."
if command -v systemctl >/dev/null 2>&1; then
  systemctl restart docker
else
  service docker restart
fi

echo "Checking Docker cgroup driver..."
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found after restart." >&2
  exit 1
fi

cgroup_driver="$(docker info --format '{{.CgroupDriver}}' 2>/dev/null || true)"
echo "Docker CgroupDriver: ${cgroup_driver}"
if [[ "${cgroup_driver}" != "cgroupfs" ]]; then
  echo "WARNING: expected cgroupfs but got '${cgroup_driver}'. Check /etc/docker/daemon.json and docker service logs." >&2
fi

echo "
Now, you need to crecreate the container with something like:

    docker compose up -d --force-recreate
"

echo "Done."
