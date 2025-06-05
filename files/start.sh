#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

#start ollama
start_ollama() {
    mkdir -p /workspace/models
    rm -fR /usr/share/ollama/.ollama/models

    echo "[+] Linking models to /workspace/models"
    mkdir -p /usr/share/ollama/.ollama
    chown -R ollama:ollama /usr/share/ollama/.ollama
    ln -s /workspace/models/ /usr/share/ollama/.ollama/models
    echo "[+] Starting Ollama server ..."
    service ollama start
    sleep 4
     echo "[+] Pulling model: qwen3:14b..."
     OLLAMA_MODELS=/workspace/models ollama pull qwen3:14b || echo "[-] Failed to pull qwen3:14b"
     echo "[+] Pulling model: qwen3:32b..."
     OLLAMA_MODELS=/workspace/models ollama pull qwen3:32b || echo "[-] Failed to pull qwen3:32b"
     echo "[+] Pulling model: devstral:24b..."
     OLLAMA_MODELS=/workspace/models ollama pull devstral:24b || echo "[-] Failed to pull devstral:24b"
     
    #  echo "[+] Pulling model: deepseek-r1:32b..."
    #  OLLAMA_MODELS=/workspace/models ollama pull deepseek-r1:32b || echo "[-] Failed to pull deepseek-r1:32b"
    #  echo "[+] Pulling model: deepseek-r1:14b..."
    #  OLLAMA_MODELS=/workspace/models ollama pull deepseek-r1:14b || echo "[-] Failed to pull deepseek-r1:14b"

}

# Start nginx service
start_nginx() {
    echo "Starting Nginx service..."
    if [[ -z $OLLAMA_SECRET_API_KEY ]]; then
        export OLLAMA_SECRET_API_KEY="Ollama FTW!"
    fi
    echo "Ollama Secret API Key: $OLLAMA_SECRET_API_KEY"   
    service nginx start
}

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

         if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
            echo "RSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
            echo "DSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_dsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
            echo "ECDSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
            echo "ED25519 key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
        fi

        service ssh start

        echo "SSH host keys:"
        for key in /etc/ssh/*.pub; do
            echo "Key: $key"
            ssh-keygen -lf $key
        done
    fi
    #Look at copying over an official default key as well
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}



# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

start_nginx

execute_script "/pre_start.sh" "Running pre-start script..."

echo "Pod Started"

setup_ssh
export_env_vars
start_ollama

execute_script "/post_start.sh" "Running post-start script..."

echo "Start script(s) finished, pod is ready to use."

sleep infinity
