#!/bin/bash
#
# Expose the SSH server (port 22) through a private zrok TCP tunnel.
#
# Usage:
#   bash run_ssh_server.sh
#
# This creates an EPHEMERAL private share and blocks, printing something like:
#   allow others to access your share with the following command:
#     zrok2 access private <share-token>
#
# Copy <share-token>, then on your LAPTOP (same zrok account, zrok2 installed):
#   zrok2 access private --bind 127.0.0.1:2222 <share-token>
#   ssh -p 2222 root@127.0.0.1
#
# Notes:
# - zrok TCP shares are private-only: there is no public HostName:Port like
#   ngrok provided. The laptop must run `zrok2 access private`.
# - Closed permission mode is the default; using the same zrok account on both
#   sides just works. Cross-account access needs --open or --access-grant.
# - Each run mints a NEW token. Reconnects = re-run this, copy the new token,
#   restart the laptop-side `access` command. VS Code SSH config stays fixed
#   at HostName 127.0.0.1 / Port 2222.
set -e

if ! command -v zrok2 &> /dev/null; then
    echo "zrok2 not found. Run install_ssh_server.sh first." >&2
    exit 1
fi

# --headless keeps the share in the foreground so the notebook cell stays alive,
# matching the old `ngrok tcp 22` behavior.
exec zrok2 share private --headless --backend-mode tcpTunnel localhost:22
