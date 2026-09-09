#!/bin/bash
#
# Install dev tools: zsh + plugins, opencode, htop/nvtop, fix .so symlinks
#
set -e

sudo apt update --allow-releaseinfo-change
sudo apt install -y zsh git curl wget htop nvtop

# --- 1) zsh + plugins (git, z, zsh-syntax-highlighting, zsh-autosuggestions) ---
export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting already installed."
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed."
fi

# Enable plugins in ~/.zshrc (git, z, zsh-syntax-highlighting, zsh-autosuggestions)
# 'z' is bundled with oh-my-zsh, 'git' too.
if [ -f "$HOME/.zshrc" ]; then
  if grep -q "^plugins=" "$HOME/.zshrc"; then
    sed -i 's/^plugins=.*/plugins=(git z zsh-syntax-highlighting zsh-autosuggestions)/' "$HOME/.zshrc"
  else
    echo 'plugins=(git z zsh-syntax-highlighting zsh-autosuggestions)' >> "$HOME/.zshrc"
  fi
else
  echo 'plugins=(git z zsh-syntax-highlighting zsh-autosuggestions)' > "$HOME/.zshrc"
fi

# Make zsh the default shell
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Setting default shell to $ZSH_PATH ..."
  sudo chsh -s "$ZSH_PATH" "$(whoami)" || chsh -s "$ZSH_PATH" || true
  # Also ensure root default if running with sudo context (best-effort)
  sudo chsh -s "$ZSH_PATH" root || true
else
  echo "zsh is already the default shell."
fi

# --- 2) opencode ---
if ! command -v opencode &> /dev/null; then
  echo "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
else
  echo "opencode already installed."
fi

# Add opencode to PATH in zsh (idempotent)
for BINDIR in "$HOME/.opencode/bin" "$HOME/.local/bin"; do
  if [ -d "$BINDIR" ] || [ "$BINDIR" = "$HOME/.opencode/bin" ]; then
    if ! grep -q "$BINDIR" "$HOME/.zshrc" 2>/dev/null; then
      echo "export PATH=\"$BINDIR:\$PATH\"" >> "$HOME/.zshrc"
    fi
  fi
done
# Also export for current session
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"

# --- 3) htop and nvtop already installed above via apt ---
echo "htop version: $(htop --version 2>&1 | head -n1 || true)"
command -v nvtop &> /dev/null && echo "nvtop installed: $(command -v nvtop)" || echo "WARNING: nvtop binary not found after apt install."

# --- 4) Fix versioned .so files then ldconfig ---
sudo bash -c '
for file in /usr/local/lib/*.so.*; do
  # If it is a regular file and NOT a symbolic link
  if [ -f "$file" ] && [ ! -L "$file" ]; then
    mv "$file" "${file}.1"
  fi
done
ldconfig
'

echo "Done. Restart shell or run: exec zsh"
