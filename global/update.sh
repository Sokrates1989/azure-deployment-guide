#!/bin/bash

# -----------------------------------------------------------------------------
# Script: update.sh
# Description: Checks for updates and performs git pull if needed.
# -----------------------------------------------------------------------------

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORIGINAL_DIR="$(pwd)"

cd "$ROOT_DIR"

# === Check for updates ===
echo ""
echo "🔍 Checking for updates..."

if git fetch --quiet && ! git diff --quiet HEAD..origin/HEAD; then
  echo "⬇️  Updates available. Pulling latest changes..."
  git pull
  echo ""
  echo "✅ Update complete."
else
  echo "✅ Already up to date with the latest version."
fi

cd "$ORIGINAL_DIR"
echo ""
