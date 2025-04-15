#!/bin/bash

# === Azure Login Check ===
if ! az account show > /dev/null 2>&1; then
  echo "🔐 Not logged in to Azure CLI."
  echo "🌐 Launching 'az login'..."
  az login
fi
