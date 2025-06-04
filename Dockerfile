FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 AS ollama-cuda
LABEL org.opencontainers.image.source=https://github.com/r26D/ollama_cuda
RUN apt-get update && apt-get install -y \
 wget \
 curl \
 git \
 ca-certificates \
 sudo \
 gnupg \
 passwd \
 gosu \
 openssh-server \
 && rm -rf /var/lib/apt/lists/*



# Install Ollama
ARG OLLAMA_INSTALL_VERSION=v0.9.0

RUN OLLAMA_VERSION=${OLLAMA_INSTALL_VERSION} curl -fsSL https://ollama.com/install.sh | sh

# Environment variables
# ENV OLLAMA_MODELS=/workspace/ollama/models
# ENV OLLAMA_MAX_CTX=65536

# Create model storage directory

# Add ollama user with sudo
RUN mkdir -p /workspace
RUN useradd -m -s /bin/bash ollama 
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

#RUN mkdir -p /workspace/models && chown -R ollama:ollama /workspace


# Expose SSH and Ollama ports (adjust as needed)
EXPOSE 22 11434

# Start SSH and Ollama
CMD service ssh start && su - ollama -c "/usr/local/bin/start_ollama.sh" && tail -f /dev/null