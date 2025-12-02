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
# Step 2: Pull Docker images
########################################

log "Pulling Docker image(s)..."
cd "${SCRIPT_DIR}"
${COMPOSE} pull

########################################
# Step 3: Start the stack (ComfyUI)
########################################

log "Bringing up ComfyUI stack..."
${COMPOSE} up -d

log "Waiting a few seconds for container to initialize..."
sleep 5

########################################
# Step 4: Clean old ComfyUI-Diffusers and install Diffusers-in-ComfyUI
########################################

log "Cleaning up any previous ComfyUI-Diffusers install (conflicts with diffusers/py3.12)..."

${COMPOSE} exec comfyui bash -lc '
  set -euo pipefail
  cd /root/ComfyUI/custom_nodes

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

log "Installing / updating diffusers & related libraries (inside container)..."

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

cat <<EOF

[setup] All done.

ComfyUI is running as a service.

  - Web UI:       http://localhost:8188
  - Data root:    ${DATA_ROOT}
  - Workflows:    ${DATA_ROOT}/storage-user/workflows
  - Outputs:      ${DATA_ROOT}/storage-user/output
  - Custom nodes: ${DATA_ROOT}/custom_nodes

We switched to "Diffusers-in-ComfyUI" to avoid the StreamDiffusion/diffusers
conflict you just hit.

Next steps:
  1) Re-open the ComfyUI web UI.
  2) Look for nodes under "Diffusers-in-Comfy" – they use Hugging Face
     Diffusers pipelines internally.
  3) Create a workflow for "Tongyi-MAI/Z-Image-Turbo" using those nodes
     (txt2img pipeline) with:
       - steps:           9
       - guidance_scale:  0.0
       - size:            1024 x 1024

You can manage the service later from ${SCRIPT_DIR} with:
  - Start: ${COMPOSE} up -d
  - Stop:  ${COMPOSE} down
  - Shell: ${COMPOSE} exec comfyui bash

EOF

