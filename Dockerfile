FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 AS base
LABEL org.opencontainers.image.source=https://github.com/r26D/ollama_cuda

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    ca-certificates \
    sudo \
    gnupg \
    passwd \
    gosu \
    adduser \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*



FROM base AS ollama-install
# Install Ollama
ARG OLLAMA_INSTALL_VERSION=v0.9.0
RUN OLLAMA_VERSION=${OLLAMA_INSTALL_VERSION} curl -fsSL https://ollama.com/install.sh | sh

FROM ollama-install AS ollama-cuda
USER root
# Create model storage directory

RUN mkdir -p /workspace /home 


# Add ollama user with sudo
RUN adduser --gecos "" --disabled-password --shell /bin/bash --debug --verbose ollama
RUN echo "ollama ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ollama && chmod 644 /etc/sudoers.d/ollama

# Set up SSH
RUN mkdir /var/run/sshd && \
    mkdir -p /home/ollama/.ssh && \
    chmod 700 /home/ollama/.ssh

# Copy public key into the authorized_keys
COPY id_ed25519.r26d-2023.pub /home/ollama/.ssh/authorized_keys
RUN chmod 600 /home/ollama/.ssh/authorized_keys && \
    chown -R ollama:ollama /home/ollama/.ssh

# Add startup script
COPY start_ollama.sh /usr/local/bin/start_ollama.sh
RUN chmod +x /usr/local/bin/start_ollama.sh

# Expose SSH and Ollama ports (adjust as needed)
EXPOSE 22 11434

# Start SSH and Ollama
CMD service ssh start && su - ollama -c "/usr/local/bin/start_ollama.sh" && tail -f /dev/null