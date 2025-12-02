#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Starting ComfyUI stack from ${SCRIPT_DIR} ..."
docker compose up -d

echo "ComfyUI should be available at http://localhost:8188"
