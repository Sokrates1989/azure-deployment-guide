#!/bin/bash

SCRIPT_PATH="$(realpath "$0")"
ROOT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# === Check if Azure CLI is installed ===
source "$ROOT_DIR/global/check-azure-cli.sh"

# === Quick Start Arguments ===
if [[ $# -gt 0 ]]; then
    case "$1" in
        --install|-i)
            bash "$ROOT_DIR/install_scripts/install_start.sh"
            exit 0
            ;;
        --change-app|-c)
            bash "$ROOT_DIR/update_scripts/update_start.sh"
            exit 0
            ;;
        --verify|-v)
            bash "$ROOT_DIR/global/azure-login-check.sh"
            exec bash "$ROOT_DIR/start.sh"
            ;;
        --update|-u)
            bash "$ROOT_DIR/global/update.sh"
            exec bash "$ROOT_DIR/start.sh"
            ;;
        *)
            echo "❌ Unknown argument: $1"
            echo ""
            echo "Usage:"
            echo "  --install    | -i    → Install new container apps"
            echo "  --change-app | -c    → Change existing container apps"
            echo "  --verify     | -v    → Verify Azure login"
            echo "  --update     | -u    → Update this tool"
            exit 1
            ;;
    esac
fi

# === Interactive Menu ===
echo ""
echo "🚀 Azure Deploy Launcher"
echo "========================"
echo "Choose what you want to do:"
echo ""
echo "1) 🏗️  Install new Container Apps          [--install | -i]"
echo "2) 🔄 Update/change already deployed apps  [--change-app| -c]"
echo ""
echo "v) 🔐 Verify Azure login                   [--verify | -v]"
echo "u) 🔄 Update this tool                     [--update | -u]"
echo "q) ❌ Exit"
echo ""

read -p "Enter your choice [1-2/v/u/q]: " choice

case "$choice" in
    1)
        bash "$ROOT_DIR/install_scripts/install_start.sh"
        ;;
    2)
        bash "$ROOT_DIR/update_scripts/update_start.sh"
        ;;
    v|V)
        bash "$ROOT_DIR/global/azure-login-check.sh"
        exec bash "$ROOT_DIR/start.sh"
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
