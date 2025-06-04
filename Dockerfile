FROM nvidia/cuda:12.3.2-devel-ubuntu22.04 AS base
LABEL org.opencontainers.image.source=https://github.com/r26D/runpod_ollama_cuda

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=True
ENV DEBIAN_FRONTEND=noninteractive

# Override the default huggingface cache directory.
ENV HF_HOME="/runpod-volume/.cache/huggingface/"
ENV HF_DATASETS_CACHE="/runpod-volume/.cache/huggingface/datasets/"
ENV DEFAULT_HF_METRICS_CACHE="/runpod-volume/.cache/huggingface/metrics/"
ENV DEFAULT_HF_MODULES_CACHE="/runpod-volume/.cache/huggingface/modules/"
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/.cache/huggingface/hub/"
ENV HUGGINGFACE_ASSETS_CACHE="/runpod-volume/.cache/huggingface/assets/"

# Faster transfer of models from the hub to the container
ENV HF_HUB_ENABLE_HF_TRANSFER="1"

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /workspace

# Update, upgrade, install packages, install python if PYTHON_VERSION is specified, clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git \
     wget \
     curl \
     bash \
     libgl1 \
     software-properties-common \
     openssh-server \
     ca-certificates \
     sudo \
     gnupg \
     gosu \
     vim \
     lshw \
    pciutils \
     nginx && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

FROM base AS ollama-install
# Install Ollama



ARG OLLAMA_INSTALL_VERSION=v0.9.0
RUN OLLAMA_VERSION=${OLLAMA_INSTALL_VERSION} curl -fsSL https://ollama.com/install.sh | sh
#RUN OLLAMA_VERSION=${OLLAMA_INSTALL_VERSION} curl -fsSL https://ollama.com/install.sh  > /installollama.sh

#Setup ollama environment variabless
RUN mkdir -p /workspace/models 
RUN  ln -s /workspace/models/ /usr/share/ollama/.ollama/models
COPY --chmod=755 files/update-ollama-env.sh /update-ollama-env.sh
RUN /update-ollama-env.sh /workspace/models 65536

COPY --chmod=755 files/ollama.init /etc/init.d/ollama
RUN update-rc.d ollama defaults



FROM ollama-install AS ollama-cuda

ENV OLLAMA_MODELS="/workspace/models"
ENV OLLAMA_MAX_CTX=65536


# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY files/proxy/nginx.conf /etc/nginx/nginx.conf
COPY files/proxy/readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Copy Scripts
COPY --chmod=755 files/start.sh /start.sh
COPY --chmod=755 files/pre_start.sh /pre_start.sh
COPY --chmod=755 files/post_start.sh /post_start.sh


# Welcome Message
COPY files/r26d-logo.txt /etc/r26d-logo.txt
RUN echo 'cat /etc/r26d-logo.txt' >> /root/.bashrc
RUN echo 'echo -e "\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/\033[0m and \033[1;34mhttps://blog.runpod.io/\033[0m\n\n"' >> /root/.bashrc

# Set the default command for the container
CMD [ "/start.sh" ]
