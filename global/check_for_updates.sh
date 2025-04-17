#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_for_updates.sh
# Description: Checks for updates in the Azure Deployment Tool Git repo
# -----------------------------------------------------------------------------

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORIGINAL_DIR="$(pwd)"

cd "$ROOT_DIR"

if git fetch --quiet && ! git diff --quiet HEAD..origin/HEAD; then
  echo ""
  echo "📦 Updates available in Azure Deployment Tool repository! (run 'az-deploy -u' to update)"
  echo ""
fi

cd "$ORIGINAL_DIR"
