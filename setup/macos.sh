#!/bin/bash

# -----------------------------------------------------------------------------
# Script: macos.sh
# Description: One-command setup for Azure Deployment Tool on macOS.
# -----------------------------------------------------------------------------

# === Step 1: Clone repo into ~/tools/az-deploy ===
if [[ ! -d ~/tools/az-deploy/.git ]]; then
  echo "📁 Cloning Azure Deployment Tool into '~/tools/az-deploy'..."
  mkdir -p ~/tools/az-deploy
  cd ~/tools/az-deploy
  git clone https://github.com/Sokrates1989/azure-deployment-guide.git .
else
  echo "ℹ️ Azure Deployment Tool already cloned – skipping git clone."
  cd ~/tools/az-deploy
fi

# === Step 2: Ensure launcher is executable ===
chmod +x ~/tools/az-deploy/start.sh

# === Step 3: Create ~/.local/bin if needed ===
mkdir -p ~/.local/bin

# === Step 4: Create a global command shortcut ===
ln -sf ~/tools/az-deploy/start.sh ~/.local/bin/az-deploy

# === Step 5: Ensure ~/.local/bin is in PATH ===
CURRENT_SHELL=$(basename "$SHELL")
EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
  SHELL_RC="$HOME/.bashrc"
else
  echo "⚠️ Unknown shell: $CURRENT_SHELL – please add ~/.local/bin to your PATH manually."
  SHELL_RC=""
fi

if [[ -n "$SHELL_RC" && -f "$SHELL_RC" ]]; then
  if ! grep -Fxq "$EXPORT_LINE" "$SHELL_RC"; then
    echo "$EXPORT_LINE" >> "$SHELL_RC"
    echo "✅ Added PATH update to $SHELL_RC"
    source "$SHELL_RC"
  else
    echo "ℹ️ PATH already set in $SHELL_RC"
  fi
fi

# === Done ===
echo ""
echo "✅ Azure Deployment Tool is set up!"
echo ""
echo "👉 You can now run it from anywhere using:"
echo ""
echo "   az-deploy"
echo ""
echo "💡 Try 'az-deploy -t' to launch a test container deployment."
echo ""
