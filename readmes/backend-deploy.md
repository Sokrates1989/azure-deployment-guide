# 🚀 Backend Deployment Guide (ACA + Caddy Proxy)

This guide walks you through the preparations and Fast Mode usage for deploying a backend container with a Caddy reverse proxy via Azure Container Apps (ACA).

---

## ⚙️ Preparations

Before starting the deployment, you'll need to:

### 1. Create a Private GitLab Repository for the Proxy

- Go to: [https://gitlab.com/projects/new](https://gitlab.com/projects/new)
- Suggested name: `projectname-proxy`
- Visibility: **Private**
- Purpose: Holds the Dockerfile + Caddyfile to build a custom reverse proxy container.

---

### 2. Create a GitLab **Deploy Token** for the Proxy Repository

Go to:  
`https://gitlab.com/<your-namespace>/<your-proxy-repo>/-/settings/repository`

Scroll down to **Deploy Tokens**:

- **Name**: `gitlab-deploy-token-backend`
- **Expires at**: 1 month (recommended)
- **Scopes**:  
  - ✅ `read_registry`  
  - ✅ `write_registry`
- After creation, **copy**:
  - **Username**: e.g. `gitlab+deploy-token-123456`
  - **Token**: This is your password (keep safe)

---

### 3. Choose & Note Down Your Deployment Values

You'll need the following:

| Variable                       | Description                                                  |
|-------------------------------|--------------------------------------------------------------|
| `Resource Group`              | Your Azure resource group (e.g., `projectname-Backend-Test`) |
| `Location`                    | Azure region (e.g., `germanywestcentral`)                   |
| `Backend App Name`            | Container App name (e.g., `projectname-backend-api`)       |
| `Backend Image`               | Full image name incl. tag (e.g., `registry.gitlab.com/youruser/backend:0.0.39`) |
| `Backend Private Image`       | Is the image private? `Yes` or `No`                         |
| `Backend Registry Username`   | Usually your GitLab username (e.g., `youruser`)             |
| `Backend Registry Token`      | A deploy token with `read_registry` access                  |
| `Caddy App Name`              | Name for the proxy (e.g., `projectname-backend-caddy-proxy`) |
| `Domain (Caddy)`              | Your public domain (e.g., `api.example.com`)                |
| `REPO_PATH_PROXY`             | e.g., `youruser/projectname-proxy`                         |
| `GITLAB_DEPLOY_USERNAME_PROXY`| e.g., `gitlab+deploy-token-123456`                          |
| `GITLAB_DEPLOY_TOKEN_PROXY`   | The token you copied from GitLab                            |

---

## 📦 Fast Mode Template

When prompted for **Fast Mode**, you can paste an edited version of the following:

```text
Resource Group            : <your-resource-group>
Location                  : <your-location>
Container Env             : <your-container-env-name>
Backend App Name          : <your-backend-app-name>
Backend Image             : registry.gitlab.com/<your-namespace>/<your-backend-image>:<tag>
Backend Private Image     : Yes
Backend Registry Server   : registry.gitlab.com
Backend Registry Username : <your-registry-username>
BACKEND_PORT              : 8000
BACKEND_CPU               : 0.5
BACKEND_MEM               : 1.0Gi
BACKEND_MIN_REPLICAS      : 1
BACKEND_MAX_REPLICAS      : 3
Caddy App Name            : <your-caddy-app-name>
Caddy Image               : caddy:latest
Domain (Caddy)            : <your-public-domain>
CADDY_CPU                 : 0.25
CADDY_MEM                 : 0.5Gi
CADDY_MIN_REPLICAS        : 1
CADDY_MAX_REPLICAS        : 3
REGISTRY_SERVER_PROXY     : registry.gitlab.com
REPO_PATH_PROXY           : <your-namespace>/<your-proxy-repo>
FULL_IMAGE_PROXY          : registry.gitlab.com/<your-namespace>/<your-proxy-repo>:latest
GITLAB_DEPLOY_USERNAME_PROXY : gitlab+deploy-token-XXXXXXX
```
