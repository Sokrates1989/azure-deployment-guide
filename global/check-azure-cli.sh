#!/bin/bash

# === Azure CLI Availability Check ===
if ! command -v az > /dev/null 2>&1; then
  echo "❌ Azure CLI (az) is not installed or not in PATH."
  echo "💡 Please install it: https://aka.ms/installazurecli"
  exit 1
fi
