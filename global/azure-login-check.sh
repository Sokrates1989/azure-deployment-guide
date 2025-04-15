#!/bin/bash

# === Azure Login Check ===
if ! az account show > /dev/null 2>&1; then
  echo "🔐 Not logged in to Azure CLI."
  echo "🌐 Launching 'az login'..."
  az login || {
    echo "❌ Azure login failed or was cancelled."
    exit 1
  }
else
  ACCOUNT_NAME=$(az account show --query user.name -o tsv 2>/dev/null)
  echo "✅ Logged in as: $ACCOUNT_NAME"
fi
