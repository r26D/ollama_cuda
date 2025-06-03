#!/bin/bash
set -e

export OLLAMA_MODELS=/workspace/models
export OLLAMA_MAX_CTX=65536

echo "[+] Pulling model: qwen:14b..."
OLLAMA_MODELS=/workspace/models  ollama pull qwen:14b
echo "[+] Pulling model: qwen:32b..."
OLLAMA_MODELS=/workspace/models ollama pull qwen:32b
echo "[+] Pulling model: deepseek-r1:32b..."
OLLAMA_MODELS=/workspace/models ollama pull deepseek-r1:32b
echo "[+] Pulling model: deepseek-r1:14b..."
OLLAMA_MODELS=/workspace/models ollama pull deepseek-r1:14b

echo "[+] Starting Ollama server with 64k context..."
OLLAMA_MODELS=/workspace/models OLLAMA_MAX_CTX=65536 ollama serve
