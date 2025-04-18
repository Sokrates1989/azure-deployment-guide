#!/bin/bash

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"


# Check for updates.
bash "$ROOT_DIR/global/check_for_updates.sh"

echo ""
echo "🏗️  Install Container Apps"
echo "=========================="
echo "Choose what you want to deploy:"
echo ""
echo "1) 🧪 Deploy test container app"
echo "2) 🎨 Deploy frontend container app"
echo "3) 🛠️  Deploy backend container app"
echo ""
echo "b) 🔙 Back to main menu"
echo "q) ❌ Exit"
echo ""

# Check for updates.
bash "$ROOT_DIR/global/check_for_updates.sh"


read -p "Enter your choice [1-3/b/q]: " choice

case "$choice" in
    1)
        bash "$SCRIPT_DIR/test-containerapp-install.sh"
        ;;
    2)
        echo "⚠️ Not implemented yet (frontend)"
        ;;
    3)
        bash "$SCRIPT_DIR/install_backend-containerapp.sh"
        ;;
    b|B)
        bash "$ROOT_DIR/start.sh"
        ;;
    q|Q)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice."
        bash "$SCRIPT_PATH/install_start.sh"
        ;;
esac
