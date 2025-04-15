#!/bin/bash

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo ""
echo "🔄 Update Deployed Container Apps"
echo "================================="

APPS=$(az containerapp list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o tsv)

if [[ -z "$APPS" ]]; then
  echo "⚠️  No Container Apps found in your Azure account."
  exit 0
fi

echo "📋 Available Container Apps:"
i=1
declare -a APP_NAMES
while IFS=$'\t' read -r name group; do
  echo "$i) $name (RG: $group)"
  APP_NAMES+=("$name::$group")
  ((i++))
done <<< "$APPS"

echo ""
read -p "Select an app to update [1-$((i-1)) or q to cancel]: " selection

if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
  echo "❌ Update cancelled."
  bash "$ROOT_DIR/start.sh"
fi

INDEX=$((selection-1))
SELECTED="${APP_NAMES[$INDEX]}"
APP_NAME="${SELECTED%%::*}"
RESOURCE_GROUP="${SELECTED##*::}"

echo "🔧 Launching update wizard for: $APP_NAME (RG: $RESOURCE_GROUP)"
bash "$SCRIPT_DIR/containerapp_update_menu.sh" "$APP_NAME" "$RESOURCE_GROUP"
