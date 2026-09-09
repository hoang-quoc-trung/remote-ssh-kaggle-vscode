#!/bin/bash
#
# Enable the zrok environment on this machine (Kaggle notebook) using your
# zrok account token.
#
# Usage:
#   bash add_zrok_token.sh YOUR_ZROK_ACCOUNT_TOKEN
#
# Get the account token from the zrok console (https://myzrok.io or your
# self-hosted instance). Use the SAME zrok account on your laptop so the
# private share below is accessible (closed permission mode default).
#
# This replaces the old ngrok authtoken step. zrok TCP shares are
# private-only: there is no public HostName:Port. Your laptop runs
# `zrok2 access private --bind 127.0.0.1:2222 <share-token>` instead.
set -e

if [ -z "$1" ]; then
    echo "Usage: bash add_zrok_token.sh YOUR_ZROK_ACCOUNT_TOKEN" >&2
    echo "Get your account token from https://myzrok.io (or your self-hosted zrok console)." >&2
    exit 1
fi

if ! command -v zrok2 &> /dev/null; then
    echo "zrok2 not found. Run install_ssh_server.sh first." >&2
    exit 1
fi

# Re-enabling over an existing environment fails, so reset it first.
# The environment identity lives in ~/.zrok2; safe to drop on ephemeral Kaggle.
if [ -d "$HOME/.zrok2" ]; then
    echo "Existing zrok environment found. Resetting it..."
    zrok2 disable || rm -rf "$HOME/.zrok2"
fi

zrok2 enable "$1"
echo "zrok environment enabled successfully."
echo "Next: run 'bash run_ssh_server.sh', copy the share token, and on your"
echo "laptop run: zrok2 access private --bind 127.0.0.1:2222 <share-token>"
