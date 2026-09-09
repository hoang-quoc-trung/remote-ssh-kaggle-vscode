#!/bin/bash
#
# Setup SSH with password authentication
# Password will be passed as argument $1
PASSWORD=${1:-"kaggle"}  # Default password is "kaggle" if not provided

echo "Setting up SSH with password: $PASSWORD"

# Set root password
echo "root:$PASSWORD" | sudo chpasswd

# Download zrok v2 (only if not already installed)
# Provides private TCP tunneling (tcpTunnel) used to expose the SSH server.
# The laptop must also install zrok2 and run `zrok2 access private` (see ReadMe).
ZROK_VERSION="v2.0.4"
if ! command -v zrok2 &> /dev/null;
then
    echo "zrok2 not found. Downloading ${ZROK_VERSION}..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) GOXARCH="amd64" ;;
        aarch64|arm64) GOXARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
    esac
    TMP_DIR=$(mktemp -d)
    wget -q "https://github.com/openziti/zrok/releases/download/${ZROK_VERSION}/zrok_${ZROK_VERSION#v}_linux_${GOXARCH}.tar.gz" -O "${TMP_DIR}/zrok.tar.gz"
    tar -xzf "${TMP_DIR}/zrok.tar.gz" -C "${TMP_DIR}"
    sudo install -o root -g root "${TMP_DIR}/zrok2" /usr/local/bin/zrok2
    rm -rf "${TMP_DIR}"
    zrok2 version
else
    echo "zrok2 is already installed."
fi

# Install SSH-Server
echo "Running apt update..."
sudo apt update --allow-releaseinfo-change

echo "Installing OpenSSH server..."
sudo apt install openssh-server -y

# SSH Config - Enable password authentication
echo "Configuring SSH..."
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config

echo "Restarting SSH service..."
sudo service ssh restart

echo "SSH Server configured successfully with password authentication!"