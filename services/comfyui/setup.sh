#!/usr/bin/env bash
set -euo pipefail

########################################
# Configuration
########################################

# Where persistent data lives on the HOST
DATA_ROOT="/data/service/comfyui"

# Directory where this script (and docker-compose.yml) live
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMPOSE="docker compose"

########################################
# Helpers
########################################

log() {
  echo "[setup] $*"
}

########################################
# Step 1: Create directory structure
########################################

log "Using data root: ${DATA_ROOT}"
log "Service dir: ${SCRIPT_DIR}"

log "Creating directory structure under ${DATA_ROOT} ..."
mkdir -p \
  "${DATA_ROOT}/storage" \
  "${DATA_ROOT}/storage-models/models" \
  "${DATA_ROOT}/storage-models/hf-hub" \
  "${DATA_ROOT}/storage-models/torch-hub" \
  "${DATA_ROOT}/storage-user/input" \
  "${DATA_ROOT}/storage-user/output" \
  "${DATA_ROOT}/storage-user/workflows" \
  "${DATA_ROOT}/custom_nodes"

########################################
# Step 2: Build Docker images
########################################

log "Building Docker image(s), including the local ComfyUI Ideogram 4 update layer..."
cd "${SCRIPT_DIR}"
${COMPOSE} build --pull comfyui image-workflow-api

########################################
# Step 3: Start the stack (ComfyUI)
########################################

log "Bringing up ComfyUI stack..."
${COMPOSE} up -d --force-recreate

log "Waiting a few seconds for container to initialize..."
sleep 5

########################################
# Step 4: Clean old ComfyUI-Diffusers and install Diffusers-in-ComfyUI
########################################

log "Cleaning up any previous ComfyUI-Diffusers install (conflicts with diffusers/py3.12)..."

${COMPOSE} exec comfyui bash -lc '
  set -euo pipefail
  cd /opt/comfyui/custom_nodes

  # Remove problematic ComfyUI-Diffusers if it exists
  if [ -d "ComfyUI-Diffusers" ]; then
    echo "[container] Removing ComfyUI-Diffusers (streamdiffusion/diffusers conflict)..."
    rm -rf ComfyUI-Diffusers
  fi

  # Install Diffusers-in-ComfyUI instead
  if [ ! -d "Diffusers-in-ComfyUI" ]; then
    echo "[container] Cloning Diffusers-in-ComfyUI..."
    git clone https://github.com/maepopi/Diffusers-in-ComfyUI.git
  else
    echo "[container] Diffusers-in-ComfyUI already present, skipping clone."
  fi

  cd Diffusers-in-ComfyUI
  echo "[container] Installing Diffusers-in-ComfyUI Python requirements (best-effort)..."
  # If some optional deps conflict, we still want the script to continue
  pip install -r requirements.txt || echo "[container] WARNING: requirements install had issues; continuing anyway."
'

########################################
# Step 5: Install latest diffusers + deps (for Z-Image)
########################################

log "Installing / updating diffusers & related libraries (inside container, for existing Z-Image workflows)..."

${COMPOSE} exec comfyui bash -lc '
  set -euo pipefail
  echo "[container] Installing diffusers (from GitHub, for Z-Image support)..."
  pip install "git+https://github.com/huggingface/diffusers"

  echo "[container] Installing / upgrading transformers, accelerate, safetensors, huggingface_hub..."
  pip install --upgrade transformers accelerate safetensors huggingface_hub
'

########################################
# Done
########################################

cat <<EOF2

[setup] All done.

ComfyUI is running as a service.

  - Web UI:       http://localhost:8188
  - Data root:    ${DATA_ROOT}
  - Workflows:    ${DATA_ROOT}/storage-user/workflows
  - Outputs:      ${DATA_ROOT}/storage-user/output
  - Custom nodes: ${DATA_ROOT}/custom_nodes

The ComfyUI service now builds a local image from:

  - Base image:   \${BASE_COMFYUI_IMAGE:-ghcr.io/lecode-official/comfyui-docker:latest}
  - ComfyUI ref:  \${COMFYUI_REF:-v0.24.0}
  - Local image:  \${COMFYUI_IMAGE:-local/comfyui-ideogram4:v0.24.0}

Ideogram 4 next steps:
  1) Run ./download_models.sh if you have not downloaded the Ideogram 4 models.
  2) Re-open the ComfyUI web UI.
  3) Search the Template Library for "Ideogram v4: Text to Image".
  4) If that template still reports missing core nodes, set COMFYUI_REF=main in .env,
     then run ./scripts/update_images.sh.

You can manage the service later from ${SCRIPT_DIR} with:
  - Start/update: ./scripts/update_images.sh
  - Stop:         ${COMPOSE} down
  - Shell:        ${COMPOSE} exec comfyui bash
  - Check:        ./scripts/check_ideogram4.sh

EOF2
