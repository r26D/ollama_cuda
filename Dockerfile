FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 AS ollama-cuda
LABEL org.opencontainers.image.source=https://github.com/r26D/ollama_cuda
RUN apt-get update && apt-get install -y \
 wget \
 curl \
 git \
 ca-certificates \
 sudo \
 gnupg \
 && rm -rf /var/lib/apt/lists/*



# Install Ollama
ARG OLLAMA_INSTALL_VERSION=v0.9.0

RUN OLLAMA_VERSION=${OLLAMA_INSTALL_VERSION} curl -fsSL https://ollama.com/install.sh | sh

# Environment variables
# ENV OLLAMA_MODELS=/workspace/models
# ENV OLLAMA_MAX_CTX=65536

# Create model storage directory
RUN mkdir -p /workspace/models

# Add startup script
COPY start_ollama.sh /usr/local/bin/start_ollama.sh
RUN chmod +x /usr/local/bin/start_ollama.sh

# Default entrypoint
CMD ["/usr/local/bin/start_ollama.sh"]
