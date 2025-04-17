#!/bin/bash

set -e

echo "🚀 Azure Backend + Caddy Installer (Dual Container Apps)"
echo "========================================================"

# === Script location (portable) ===
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# === Load helpers ===
source "$ROOT_DIR/global/azure-login-check.sh"
source "$ROOT_DIR/global/common.sh"


### === Fast mode? ===
read -rp "Have you already created a backend with this script before and want to paste an edited summary for fast usage? (fast mode)? (y/n) [n]: " FAST_MODE
FAST_MODE=${FAST_MODE:-n}

if [[ "$FAST_MODE" == "y" ]]; then
  echo ""
  echo "📋 Please paste your input summary (copy of the deployment summary WITHOUT EMPTY LINES from a previous run):"
  echo "    ➤ You can modify any values beforehand"
  echo "    ➤ Example format:"
  echo '      Resource Group: MyGroup'
  echo '      Location: westeurope'
  echo '      Backend Image: docker.io/your/backend:tag'
  echo ""
  echo "🔽 Paste your block below. End input with an empty line:"
  
  INPUT_BLOCK=""
  while IFS= read -r LINE; do
    [[ -z "$LINE" ]] && break
    INPUT_BLOCK+="$LINE"$'\n'
  done

  # Parse values from the block using pattern matching
  RESOURCE_GROUP=$(echo "$INPUT_BLOCK" | grep -i "Resource Group" | cut -d: -f2- | xargs)
  LOCATION=$(echo "$INPUT_BLOCK" | grep -i "Location" | cut -d: -f2- | xargs)
  CONTAINER_ENV_NAME=$(echo "$INPUT_BLOCK" | grep -i "Container Env" | cut -d: -f2- | xargs)
  BACKEND_APP_NAME=$(echo "$INPUT_BLOCK" | grep -i "Backend App Name" | cut -d: -f2- | xargs)
  BACKEND_IMAGE=$(echo "$INPUT_BLOCK" | grep -i "Backend Image" | cut -d: -f2- | xargs)
  BACKEND_PORT=$(echo "$INPUT_BLOCK" | grep -i "BACKEND_PORT" | cut -d: -f2- | xargs)
  BACKEND_CPU=$(echo "$INPUT_BLOCK" | grep -i "BACKEND_CPU" | cut -d: -f2- | xargs)
  BACKEND_MEM=$(echo "$INPUT_BLOCK" | grep -i "BACKEND_MEM" | cut -d: -f2- | xargs)
  BACKEND_MIN_REPLICAS=$(echo "$INPUT_BLOCK" | grep -i "BACKEND_MIN_REPLICAS" | cut -d: -f2- | xargs)
  BACKEND_MAX_REPLICAS=$(echo "$INPUT_BLOCK" | grep -i "BACKEND_MAX_REPLICAS" | cut -d: -f2- | xargs)
  IS_PRIVATE=$(echo "$INPUT_BLOCK" | grep -i "Backend Private Image" | grep -iq "yes" && echo "y" || echo "n")
  REGISTRY_SERVER_BACKEND=$(echo "$INPUT_BLOCK" | grep -i "Registry Server" | cut -d: -f2- | xargs)
  REGISTRY_USERNAME_BACKEND=$(echo "$INPUT_BLOCK" | grep -i "Registry Username" | cut -d: -f2- | xargs)
  CADDY_APP_NAME=$(echo "$INPUT_BLOCK" | grep -i "Caddy App Name" | cut -d: -f2- | xargs)
  PUBLIC_DOMAIN=$(echo "$INPUT_BLOCK" | grep -i "Domain (Caddy)" | cut -d: -f2- | xargs)
  CADDY_CPU=$(echo "$INPUT_BLOCK" | grep -i "CADDY_CPU" | cut -d: -f2- | xargs)
  CADDY_MEM=$(echo "$INPUT_BLOCK" | grep -i "CADDY_MEM" | cut -d: -f2- | xargs)
  CADDY_MIN_REPLICAS=$(echo "$INPUT_BLOCK" | grep -i "CADDY_MIN_REPLICAS" | cut -d: -f2- | xargs)
  CADDY_MAX_REPLICAS=$(echo "$INPUT_BLOCK" | grep -i "CADDY_MAX_REPLICAS" | cut -d: -f2- | xargs)
  REGISTRY_SERVER_PROXY=$(echo "$INPUT_BLOCK" | grep -i "REGISTRY_SERVER_PROXY" | cut -d: -f2- | xargs)
  REPO_PATH_PROXY=$(echo "$INPUT_BLOCK" | grep -i "REPO_PATH_PROXY" | cut -d: -f2- | xargs)
  FULL_IMAGE_PROXY=$(echo "$INPUT_BLOCK" | grep -i "FULL_IMAGE_PROXY" | cut -d: -f2- | xargs)
  GITLAB_DEPLOY_USERNAME_PROXY=$(echo "$INPUT_BLOCK" | grep -i "GITLAB_DEPLOY_USERNAME_PROXY" | cut -d: -f2- | xargs)


  # === TOKENs still needs to be entered manually and securely ===
  if [[ "$IS_PRIVATE" == "y" ]]; then
    echo -n "🔐 Enter token with read access for Backend Registry Username $REGISTRY_USERNAME_BACKEND (hidden): "
    read -rs REGISTRY_TOKEN_BACKEND
    echo
  fi

  echo -n "🔐 Enter GitLab token for GITLAB_DEPLOY_USERNAME_PROXY $GITLAB_DEPLOY_USERNAME_PROXY (hidden): "
  read -rs GITLAB_DEPLOY_TOKEN_PROXY
  echo

  echo "✅ All values parsed from summary!"
else









  # === No Fast mode - manual input ===

  # === Prepare proxy repo first as this might cause most work ===
  echo ""
  echo "🛠️  Let's prepare your custom Caddy proxy image."

  # === Does Proxy repo exist ===
  read -rp "Do you already have a GitLab repository for the proxy image? (y/n) [n]: " HAS_PROXY_REPO
  HAS_PROXY_REPO=${HAS_PROXY_REPO:-n}
  if [[ "$HAS_PROXY_REPO" != "y" ]]; then
    echo ""
    echo "📘 Please create a private GitLab repository manually:"
    echo "   ➤ Visit: https://gitlab.com/projects/new"
    echo "   ➤ Suggested name: caddy-proxy-projectname"
    echo "   ➤ Set visibility to: Private"
    echo "   ➤ Provision target: No provision planned"
    echo "   ➤ 🏁 Create Project"
    echo ""
    echo "🚦 Press [ENTER] when you're done..."
    read
  fi


  # === Ask for the full repo path (namespace/image-name) ===
  REGISTRY_SERVER_PROXY=$(ask "Enter the registry server for the proxy image" "registry.gitlab.com")
  REPO_PATH_PROXY=$(ask "Enter full repo path (e.g. youruser/caddy-proxy-projectname)" "")

  # === Set image tag ===
  IMAGE_TAG_PROXY=$(ask "Image tag for the proxy (e.g. 0.0.5)" "latest")
  FULL_IMAGE_PROXY="$REGISTRY_SERVER_PROXY/$REPO_PATH_PROXY:$IMAGE_TAG_PROXY"

  # === Does Proxy repo have valid token ===
  read -rp "Do you already have a GitLab Token with write_registry and read_registry permission for that repo ? (y/n) [n]: " HAS_PROXY_TOKEN
  HAS_PROXY_TOKEN=${HAS_PROXY_TOKEN:-n}
  if [[ "$HAS_PROXY_TOKEN" != "y" ]]; then
    echo "📘 Please create a GitLab Token with write_registry and read_registry permission manually:"
    echo "   ➤ Visit: https://gitlab.com/${REPO_PATH_PROXY}/-/settings/repository#js-deploy-tokens"
    echo "   ➤ Suggested Token name       : caddy-proxy-projectname-deploy-token"
    echo "   ➤ Suggested Token description: Used by az-deploy (https://github.com/Sokrates1989/azure-deployment-guide) to build and push a Caddy Docker image to GitLab Container Registry for Azure deployment"
    echo "   ➤ Suggested expiry date      : 1 month"
    echo "   ➤ Choose permissions         : ✅ write_registry"
    echo "                                  ✅ read_registry"
    echo "   ➤ 🏁 Create token"
    echo "   ➤ Save token and user securely somewhere safe (e.g., password manager)"
    echo ""
    echo "🚦 Press [ENTER] when you're done..."
    read
  fi

  # === Ask for registry credentials to push image ===
  echo "🔐 GitLab Registry Credentials for pushing the image:"
  echo "ℹ️  You can verify if your username/token combination works by running the following command:"
  echo 'echo -n "Enter GitLab username: "; read USER; echo -n "Enter GitLab token: "; read -s TOKEN; echo; echo "$TOKEN" | docker login registry.gitlab.com -u "$USER" --password-stdin'
  GITLAB_DEPLOY_USERNAME_PROXY=$(ask "Enter the created deploy username for the deploy token" "")
  echo -n "Enter a GitLab token with write_registry and read_registry permission for the proxy repo (input hidden): "
  read -rs GITLAB_DEPLOY_TOKEN_PROXY
  echo

  # === Interactive inputs ===
  RESOURCE_GROUP=$(ask "Enter the resource group name" "Backend")
  LOCATION=$(ask "Enter the Azure location" "germanywestcentral")
  CONTAINER_ENV_NAME=$(ask "Enter the container environment name" "containerenv-${RESOURCE_GROUP}")

  BACKEND_APP_NAME=$(ask "Enter the backend container app name" "backend-api")
  BACKEND_IMAGE=$(ask "Enter your backend image (e.g. docker.io/user/myapi:latest)" "")

  # === Private image handling ===
  read -rp "Is the backend image private? (y/n) [n]: " IS_PRIVATE
  IS_PRIVATE=${IS_PRIVATE:-n}

  if [[ "$IS_PRIVATE" == "y" ]]; then
    REGISTRY_SERVER_BACKEND=$(ask "Enter container registry server (e.g. registry.gitlab.com)" "registry.gitlab.com")
    REGISTRY_USERNAME_BACKEND=$(ask "Enter registry username" "")
    echo -n "Enter registry token with read_registry permission (input will be hidden): "
    read -rs REGISTRY_TOKEN_BACKEND
    echo
  else
    REGISTRY_SERVER_BACKEND=""
    REGISTRY_USERNAME_BACKEND=""
    REGISTRY_TOKEN_BACKEND=""
  fi

  BACKEND_PORT=$(ask "Enter the backend container port" "8000")
  BACKEND_CPU=$(ask "Enter CPU for backend" "0.5")
  BACKEND_MEM=$(ask "Enter memory for backend" "1.0Gi")
  BACKEND_MIN_REPLICAS=$(ask "Enter min replicas for backend" "1")
  BACKEND_MAX_REPLICAS=$(ask "Enter max replicas for backend" "3")

  CADDY_APP_NAME=$(ask "Enter the Caddy reverse proxy app name" "caddy-proxy")
  CADDY_IMAGE=$(ask "Enter the Caddy image" "caddy:latest")
  PUBLIC_DOMAIN=$(ask "Enter your public domain (for Caddy TLS)" "api.example.com")
  CADDY_CPU=$(ask "Enter CPU for Caddy" "0.25")
  CADDY_MEM=$(ask "Enter memory for Caddy" "0.5Gi")
  CADDY_MIN_REPLICAS=$(ask "Enter min replicas for Caddy" "1")
  CADDY_MAX_REPLICAS=$(ask "Enter max replicas for Caddy" "3")
fi




echo
echo "🔧 Summary (copy this somewhere to enable fast mode for next deployment):"
echo
echo "Resource Group            : $RESOURCE_GROUP"
echo "Location                  : $LOCATION"
echo "Container Env             : $CONTAINER_ENV_NAME"
echo
echo "Backend App Name          : $BACKEND_APP_NAME"
echo "Backend Image             : $BACKEND_IMAGE"
echo "Backend Private Image     : $([[ "$IS_PRIVATE" == "y" ]] && echo "Yes" || echo "No")"
[[ "$IS_PRIVATE" == "y" ]] && {
  echo "Backend Registry Server   : $REGISTRY_SERVER_BACKEND"
  echo "Backend Registry Username : $REGISTRY_USERNAME_BACKEND"
  echo "Backend Registry Token    : ********"
}
echo "BACKEND_PORT              : $BACKEND_PORT"
echo "BACKEND_CPU               : $BACKEND_CPU"
echo "BACKEND_MEM               : $BACKEND_MEM"
echo "BACKEND_MIN_REPLICAS      : $BACKEND_MIN_REPLICAS"
echo "BACKEND_MAX_REPLICAS      : $BACKEND_MAX_REPLICAS"
echo
echo "Caddy App Name            : $CADDY_APP_NAME"
echo "Caddy Image               : $CADDY_IMAGE"
echo "Domain (Caddy)            : $PUBLIC_DOMAIN"
echo "CADDY_CPU                 : $CADDY_CPU"
echo "CADDY_MEM                 : $CADDY_MEM"
echo "CADDY_MIN_REPLICAS        : $CADDY_MIN_REPLICAS"
echo "CADDY_MAX_REPLICAS        : $CADDY_MAX_REPLICAS"
echo
echo "REGISTRY_SERVER_PROXY     : $REGISTRY_SERVER_PROXY"
echo "REPO_PATH_PROXY           : $REPO_PATH_PROXY"
echo "FULL_IMAGE_PROXY          : $FULL_IMAGE_PROXY"
echo "GITLAB_DEPLOY_USERNAME_PROXY     : $GITLAB_DEPLOY_USERNAME_PROXY"
echo "GITLAB_DEPLOY_TOKEN_PROXY        : ********"
echo
echo
echo "🔧 END Summary (copy above somewhere to enable fast mode for next deployment):"
echo

read -rp "Proceed with deployment? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}
[[ "$CONFIRM" != "y" ]] && echo "❌ Cancelled." && exit 1

# === Resource group and env ===
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
az containerapp env create \
  --name "$CONTAINER_ENV_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"


# === Build the backend container app create command ===
# This supports both public and private container registries by conditionally appending registry credentials.
BACKEND_CREATE_CMD=(
  az containerapp create
  --name "$BACKEND_APP_NAME"
  --resource-group "$RESOURCE_GROUP"
  --environment "$CONTAINER_ENV_NAME"
  --image "$BACKEND_IMAGE"
  --target-port "$BACKEND_PORT"
  --ingress internal  # ensures the backend is only accessible within the ACA environment
  --cpu "$BACKEND_CPU"
  --memory "$BACKEND_MEM"
  --min-replicas "$BACKEND_MIN_REPLICAS"
  --max-replicas "$BACKEND_MAX_REPLICAS"
)

# === If image is private, append registry authentication ===
if [[ "$IS_PRIVATE" == "y" ]]; then
  BACKEND_CREATE_CMD+=(
    --registry-server "$REGISTRY_SERVER_BACKEND"
    --registry-username "$REGISTRY_USERNAME_BACKEND"
    --registry-password "$REGISTRY_TOKEN_BACKEND"
  )
fi

# === Execute the composed backend deployment command ===
"${BACKEND_CREATE_CMD[@]}"


# === Retrieve and print internal FQDN URL ===
BACKEND_FQDN=$(az containerapp show \
  --name "$BACKEND_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)
echo "✅ Backend App deployed (internal): $BACKEND_FQDN"


# === Build image with dynamic backend FQDN. ===
TMP_PROXY_DIR=$(mktemp -d)
CADDYFILE_PATH="$TMP_PROXY_DIR/Caddyfile"
DOCKERFILE_PATH="$TMP_PROXY_DIR/Dockerfile"

# === Create Caddyfile content dynamically ===
cat > "$CADDYFILE_PATH" <<EOF
$PUBLIC_DOMAIN {
  reverse_proxy http://$BACKEND_FQDN
}
EOF

# === Create Dockerfile ===
cat > "$DOCKERFILE_PATH" <<EOF
FROM caddy:latest
COPY Caddyfile /etc/caddy/Caddyfile
EOF

# === Build and push the Docker image for amd64 platform ===
echo "🐳 Building and pushing custom Caddy image..."
echo "$GITLAB_DEPLOY_TOKEN_PROXY" | docker login "$REGISTRY_SERVER_PROXY" -u "$GITLAB_DEPLOY_USERNAME_PROXY" --password-stdin
docker buildx build \
  --platform linux/amd64 \
  --push \
  -t "$FULL_IMAGE_PROXY" \
  "$TMP_PROXY_DIR"

# === Success build message ===
CADDY_IMAGE="$FULL_IMAGE_PROXY"
echo "✅ Proxy image pushed as $CADDY_IMAGE"




# === Create Caddy app without startup logic. ===
az containerapp create \
  --name "$CADDY_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$CONTAINER_ENV_NAME" \
  --image "$CADDY_IMAGE" \
  --target-port 80 \
  --ingress external \
  --cpu "$CADDY_CPU" \
  --memory "$CADDY_MEM" \
  --min-replicas "$CADDY_MIN_REPLICAS" \
  --max-replicas "$CADDY_MAX_REPLICAS" \
  --registry-server "$REGISTRY_SERVER_PROXY" \
  --registry-username "$GITLAB_DEPLOY_USERNAME_PROXY" \
  --registry-password "$GITLAB_DEPLOY_TOKEN_PROXY"


# === App URL ===
CADDY_FQDN=$(az containerapp show \
  --name "$CADDY_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)



# === Success message and summary ===

# remove any protocol from PUBLIC_DOMAIN for CNAME display
PUBLIC_DOMAIN_CNAME=$(echo "$PUBLIC_DOMAIN" | sed 's~^[a-z]*://~~')

echo
echo "🏁 Success Summary:"
echo
echo "✅ Backend App deployed (internal): $BACKEND_FQDN"
echo "✅ Proxy image pushed as $CADDY_IMAGE"
echo "✅ Caddy Proxy App deployed (external): https://$CADDY_FQDN"
echo
echo "📝 To use your configured public domain ($PUBLIC_DOMAIN), make sure to update your DNS settings:"
echo "   ➤ ✅ Add a CNAME record pointing '$PUBLIC_DOMAIN_CNAME' to:"
echo "     ➝ $CADDY_FQDN"
echo
echo "📘 This can be done via your DNS provider (e.g. IONOS, Strato, Cloudflare, etc.)"
echo "⚠️  Important:"
echo "   ➤ If an A-Record already exists for '$PUBLIC_DOMAIN_CNAME', delete it before adding the CNAME."
echo "   ➤ CNAME records are exclusive – adding one will likely remove all conflicting records (like MX, TXT, etc.)."
echo "     ➝ This is intended for this deployment if the domain is not used for mail."
echo
echo "🔎 Once updated, you can verify your domain is correctly pointing to the proxy with:"
echo "   ➤ dig +short CNAME ${PUBLIC_DOMAIN_CNAME}"
echo
