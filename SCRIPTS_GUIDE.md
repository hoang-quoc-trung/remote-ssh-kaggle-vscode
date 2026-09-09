# 🔧 Bash Scripts Guide

This repository uses modular bash scripts to set up SSH server on Kaggle with password authentication. Here's what each script does:

## 📁 Scripts Overview

### 1. `install_ssh_server.sh`
**Purpose:** Sets up SSH server with password authentication

**Usage:**
```bash
bash install_ssh_server.sh [PASSWORD]
```

**Parameters:**
- `PASSWORD` (optional): Your desired SSH password. Default is "kaggle" if not provided.

**What it does:**
1. Sets root password for SSH authentication
2. Downloads and installs zrok v2 (`zrok2` binary, pinned version) if not already installed
3. Installs OpenSSH server
4. Configures SSH to allow:
   - Root login
   - Password authentication
   - Public key authentication (optional)
5. Restarts SSH service

**Example:**
```python
# In Kaggle notebook
ssh_password = "my_secure_password"
!bash install_ssh_server.sh $ssh_password
```

---

### 2. `add_zrok_token.sh`
**Purpose:** Enables the zrok environment with your zrok account token

**Usage:**
```bash
bash add_zrok_token.sh YOUR_ZROK_ACCOUNT_TOKEN
```

**Parameters:**
- `YOUR_ZROK_ACCOUNT_TOKEN`: Your zrok account token from https://myzrok.io (or your self-hosted zrok console)

**What it does:**
1. Verifies `zrok2` is installed (run `install_ssh_server.sh` first)
2. Resets any existing environment in `~/.zrok2` (safe on ephemeral Kaggle)
3. Runs `zrok2 enable` with your account token

> Use the **same** zrok account on Kaggle and on your laptop. Private shares
> default to closed permission mode, so same-account access just works.

**Example:**
```python
# In Kaggle notebook
!bash add_zrok_token.sh YOUR_ZROK_ACCOUNT_TOKEN
```

---

### 3. `run_ssh_server.sh`
**Purpose:** Starts a private zrok TCP tunnel exposing the SSH server

**Usage:**
```bash
bash run_ssh_server.sh
```

**Parameters:** None

**What it does:**
1. Starts an ephemeral private share: `zrok2 share private --headless --backend-mode tcpTunnel localhost:22`
2. Prints a share token, e.g. `zrok2 access private abc123`

**Output:**
```
allow others to access your share with the following command:
  zrok2 access private abc123
```

Copy the token, then on your **laptop** (same zrok account, `zrok2` installed):
```bash
zrok2 access private --bind 127.0.0.1:2222 abc123
ssh -p 2222 root@127.0.0.1
```

> Unlike ngrok, zrok TCP shares are private-only: there is no public
> `HostName:Port`. The laptop must run `zrok2 access private`, and the VS Code
> SSH config stays fixed at `HostName 127.0.0.1 / Port 2222`. Each run mints a
> new token — reconnects just need the new token, not a new SSH config host.

**Example:**
```python
# In Kaggle notebook
!bash run_ssh_server.sh
```

---

## 🛠️ Customization

### Change Default Password
Edit `install_ssh_server.sh` line 4:
```bash
PASSWORD=${1:-"your_new_default_password"}
```

### Change Pinned zrok2 Version
Edit `install_ssh_server.sh`:
```bash
ZROK_VERSION="v2.0.4"
```

### Change Local Bind Port
On your laptop, pick any free local port:
```bash
zrok2 access private --bind 127.0.0.1:2222 <share-token>  # or e.g. 127.0.0.1:2223
```
Match the `Port` in your VS Code SSH config to whatever you bound.

### Add Additional SSH Configuration
Edit `install_ssh_server.sh` in the "SSH Config" section, before `sudo service ssh restart`:
```bash
sudo echo "YourCustomConfig yes" >> /etc/ssh/sshd_config
```