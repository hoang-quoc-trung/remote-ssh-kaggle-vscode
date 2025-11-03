#!/bin/bash
#
# Setup SSH with password authentication
# Password will be passed as argument $1
PASSWORD=${1:-"kaggle"}  # Default password is "kaggle" if not provided

echo "Setting up SSH with password: $PASSWORD"

# Set root password
echo "root:$PASSWORD" | sudo chpasswd

# Download ngrok (only if not already installed)
if ! command -v ngrok &> /dev/null;
then
    echo "ngrok not found. Downloading..."
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    sudo tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
    rm ngrok-v3-stable-linux-amd64.tgz
else
    echo "ngrok is already installed."
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