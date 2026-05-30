#!/usr/bin/env bash
set -euo pipefail

# Build the lightweight wrapper and start both services.
# The ComfyUI image is remote; image-workflow-api is local-built.
docker compose up -d --build

echo
echo "ComfyUI:            http://localhost:${COMFYUI_PORT:-8188}"
echo "Image Workflow API: http://localhost:${IMAGE_WORKFLOW_API_PORT:-8190}"
echo
echo "Useful checks:"
echo "  curl -s http://localhost:${IMAGE_WORKFLOW_API_PORT:-8190}/health | jq"
echo "  curl -s http://localhost:${COMFYUI_PORT:-8188}/system_stats | jq"
