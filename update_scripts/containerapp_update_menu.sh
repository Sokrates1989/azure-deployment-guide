#!/bin/bash

set -e

echo "🔧 Azure Container App – Update Options"
echo "======================================="

# === Script metadata ===
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# === Load helpers ===
source "$ROOT_DIR/global/azure-login-check.sh"
source "$ROOT_DIR/global/common.sh"

# === Get required inputs via args only ===
APP_NAME="$1"
RESOURCE_GROUP="$2"

if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" ]]; then
  echo "❌ Missing parameters."
  echo "Usage: ./containerapp_update_menu.sh <APP_NAME> <RESOURCE_GROUP>"
  exit 1
fi

echo ""
echo "🛠️  What would you like to update on '$APP_NAME' (RG: $RESOURCE_GROUP)?"
echo "1) 🔁 Min/Max replicas"
echo "2) ⚖️  Add or change autoscaling rule"
echo "3) 🐳 Container image"
echo "q) ❌ Cancel"
echo ""

read -p "Enter your choice [1-3/q]: " updateChoice

case "$updateChoice" in
  1)
    MIN_REPLICAS=$(ask "Enter minimum number of replicas" "1")
    MAX_REPLICAS=$(ask "Enter maximum number of replicas" "3")
    az containerapp update \
      --name "$APP_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --min-replicas "$MIN_REPLICAS" \
      --max-replicas "$MAX_REPLICAS"
    ;;

  2)
    RULE_NAME=$(ask "Enter name for the scaling rule" "http-rule")
    RULE_TYPE=$(ask "Enter scaling rule type (http/cpu/memory)" "http")

    case "$RULE_TYPE" in
      http)
        CONCURRENCY=$(ask "Enter HTTP concurrency threshold" "50")
        az containerapp update \
          --name "$APP_NAME" \
          --resource-group "$RESOURCE_GROUP" \
          --scale-rule-name "$RULE_NAME" \
          --scale-rule-type http \
          --scale-rule-http-concurrency "$CONCURRENCY"
        ;;
      cpu)
        CPU_UTIL=$(ask "Enter CPU utilization threshold (%)" "70")
        az containerapp update \
          --name "$APP_NAME" \
          --resource-group "$RESOURCE_GROUP" \
          --scale-rule-name "$RULE_NAME" \
          --scale-rule-type cpu \
          --scale-rule-metadata "type=Utilization,value=$CPU_UTIL"
        ;;
      memory)
        MEM_UTIL=$(ask "Enter memory utilization threshold (%)" "75")
        az containerapp update \
          --name "$APP_NAME" \
          --resource-group "$RESOURCE_GROUP" \
          --scale-rule-name "$RULE_NAME" \
          --scale-rule-type memory \
          --scale-rule-metadata "type=Utilization,value=$MEM_UTIL"
        ;;
      *)
        echo "❌ Unsupported rule type: $RULE_TYPE"
        exit 1
        ;;
    esac
    ;;

  3)
    NEW_IMAGE=$(ask "Enter the new container image" "docker.io/your/image:latest")
    az containerapp update \
      --name "$APP_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --image "$NEW_IMAGE"
    ;;

  q|Q)
    echo "❌ Update cancelled."
    exit 0
    ;;

  *)
    echo "❌ Invalid choice."
    ;;
esac


# === Show updated app URL ===
FQDN=$(az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo
echo "✅ Update complete!"
echo "🌐 Your app is live at: https://$FQDN"