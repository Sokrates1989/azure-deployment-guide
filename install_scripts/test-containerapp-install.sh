#!/bin/bash

set -e

echo "🚀 Welcome to the Azure Test Container App Installer"
echo "----------------------------------------------"


# === Script location (portable) ===
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# === Load helpers ===
source "$ROOT_DIR/global/azure-login-check.sh"
source "$ROOT_DIR/global/common.sh"

# === Interactive questions ===
RESOURCE_GROUP=$(ask "Enter the resource group name" "Test")
LOCATION=$(ask "Enter the Azure location" "germanywestcentral")
CONTAINER_ENV_NAME=$(ask "Enter the container environment name" "containerenv-${RESOURCE_GROUP}")
APP_NAME=$(ask "Enter the container app name" "container-app-test-cli")
IMAGE=$(ask "Enter the container image (e.g. docker.io/nginxdemos/hello)" "docker.io/nginxdemos/hello")
PORT=$(ask "Enter the container port" "80")
CPU=$(ask "Enter the number of CPUs" "0.5")
MEMORY=$(ask "Enter memory size (e.g. 1.0Gi)" "1.0Gi")
MIN_REPLICAS=$(ask "Enter minimum number of replicas" "0")
MAX_REPLICAS=$(ask "Enter maximum number of replicas" "1")

echo
echo "🔧 Configuration Summary:"
echo "   Resource Group       : $RESOURCE_GROUP"
echo "   Location             : $LOCATION"
echo "   Container Env Name   : $CONTAINER_ENV_NAME"
echo "   Container App Name   : $APP_NAME"
echo "   Image                : $IMAGE"
echo "   Port                 : $PORT"
echo "   CPU                  : $CPU"
echo "   Memory               : $MEMORY"
echo

read -rp "Proceed with deployment? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}
if [[ "$CONFIRM" != "y" ]]; then
  echo "❌ Deployment cancelled."
  exit 1
fi

# === Deployment ===
echo "📦 Creating resource group (if needed)..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "🌱 Creating container environment (if needed)..."
az containerapp env create \
  --name "$CONTAINER_ENV_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "🚢 Deploying container app..."
az containerapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$CONTAINER_ENV_NAME" \
  --image "$IMAGE" \
  --target-port "$PORT" \
  --ingress external \
  --cpu "$CPU" \
  --memory "$MEMORY" \
  --min-replicas "$MIN_REPLICAS" \
  --max-replicas "$MAX_REPLICAS"

# === App URL ===
FQDN=$(az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo
echo "✅ Deployment complete!"
echo "🌐 Your app is live at: https://$FQDN"

