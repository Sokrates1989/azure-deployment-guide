#!/bin/bash

SCRIPT_PATH="$(realpath "$0")"
ROOT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# === Check if Azure CLI is installed ===
source "$ROOT_DIR/global/check-azure-cli.sh"

# === Quick Start Arguments ===
if [[ $# -gt 0 ]]; then
    case "$1" in
        --test|-t)
            bash "$ROOT_DIR/install_scripts/deploy-azure-containerapp.sh"
            exit 0
            ;;
        --update|-u)
            bash "$ROOT_DIR/global/update.sh"
            exec bash "$ROOT_DIR/start.sh"
            ;;
        --verify|-v)
            bash "$ROOT_DIR/global/azure-login-check.sh"
            exit 0
            ;;
        *)
            echo "❌ Unknown argument: $1"
            echo ""
            echo "Usage:"
            echo "  --test   | -t   → Deploy Azure Test Container App"
            echo "  --update | -u   → Run update for this tool"
            exit 1
            ;;
    esac
fi

# === Interactive Menu ===
echo ""
echo "🚀 Azure Deploy Launcher"
echo "========================"
echo "Choose a deployment option (or use flags directly):"
echo ""
echo "1) 🚀 Deploy Azure Test Container App     [--test   | -t]"
echo ""
echo "v) 🔐 Verify Azure login status           [--verify | -v]"
echo "u) 🔄 Update this tool                    [--update | -u]"
echo "q) ❌ Exit"

echo ""

read -p "Enter your choice [1/v/u/q]: " choice

case "$choice" in
    1)
        bash "$ROOT_DIR/install_scripts/deploy-azure-containerapp.sh"
        ;;
    v|V)
        bash "$ROOT_DIR/global/azure-login-check.sh"
        ;;
    u|U)
        bash "$ROOT_DIR/global/update.sh"
        exec bash "$ROOT_DIR/start.sh"
        ;;
    q|Q)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice."
        ;;
esac
