#!/bin/bash

# Exit on error
set -e

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <models_path> <max_ctx>"
    echo "Example: $0 /workspace/models 65536"
    exit 1
fi

MODELS_PATH="$1"
MAX_CTX="$2"
BASHRC_FILE="/usr/share/ollama/.bashrc"
ROOT_BASHRC_FILE="/root/.bashrc"

# Update or append to bashrc
sudo touch "$BASHRC_FILE"
sudo sed -i '/^export OLLAMA_MODELS=/d' "$BASHRC_FILE"
sudo sed -i '/^export OLLAMA_MAX_CTX=/d' "$BASHRC_FILE"
echo "export OLLAMA_MODELS=${MODELS_PATH}" | sudo tee -a "$BASHRC_FILE" > /dev/null
echo "export OLLAMA_MAX_CTX=${MAX_CTX}" | sudo tee -a "$BASHRC_FILE" > /dev/null


# Update or append to bashrc
sudo touch "$ROOT_BASHRC_FILE"
sudo sed -i '/^export OLLAMA_MODELS=/d' "$ROOT_BASHRC_FILE"
sudo sed -i '/^export OLLAMA_MAX_CTX=/d' "$ROOT_BASHRC_FILE"
echo "export OLLAMA_MODELS=${MODELS_PATH}" | sudo tee -a "$ROOT_BASHRC_FILE" > /dev/null
echo "export OLLAMA_MAX_CTX=${MAX_CTX}" | sudo tee -a "$ROOT_BASHRC_FILE" > /dev/null


echo "✅ Updated $ROOT_BASHRC_FILE and $BASHRC_FILE with:"
echo "   OLLAMA_MODELS=${MODELS_PATH}"
echo "   OLLAMA_MAX_CTX=${MAX_CTX}"
