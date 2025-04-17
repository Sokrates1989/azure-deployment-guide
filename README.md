# 🚀 Azure Deployment Guide – Focus: Azure Container Apps (ACA)

## 📜 Description

This guide walks you through deploying container-based applications on Azure, with a primary focus on **Azure Container Apps (ACA)**. It also highlights the differences between **Azure Container Instances (ACI)** and ACA to help you choose the right tool for the job.

---

## 📚 Table of Contents

1. [📖 Overview](#-overview)    
2. [⚙️ Prerequisites](#️-prerequisites)  
   - [☁️ AZ Login](#️-az-login)  
   - [🐳 Docker](#-docker-needed-for-deploying-backend)  
   - [🔧 Docker Buildx](#-docker-buildx-needed-for-deploying-backend)
3. [📦 One-Command Setup (macOS)](#-one-command-setup-macos)
4. [📊 ACA vs. ACI](#-aca-vs-aci)  
5. [🧑‍💻 Usage](#-usage)  
   - [▶️ Simple Usage](#️-simple-usage)  
   - [🔀 Quick Options](#-quick-options)  
   - [⚡ Advanced Usage: Fast Mode](#-advanced-usage-fast-mode)
     - [📄 Template for Backend Deploy](#-template-for-backend-deploy)
6. [🚀 Summary](#-summary)  


---

## 📖 Overview

Azure offers multiple ways to run containers. **ACI** is great for simple and short-lived workloads, while **ACA** provides a powerful, scalable platform for modern applications and microservices.

This guide focuses on ACA as the long-term solution for scalable, production-grade deployments.  
To make onboarding easy, we provide a **single shell script** that:

- Automatically installs the tooling under `~/tools/az-deploy`
- Sets up a globally accessible command: `az-deploy`
- Launches an interactive CLI assistant to help you deploy and update azure container apps (ACA)

---

## ⚙️ Prerequisites

Make sure you have the following setup before continuing:

### ☁️ AZ Login

```
# Azure CLI must be installed:
# Installation help → https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
az version

# Log in to Azure:
az login

# Select your subscription:
az account set --subscription "<name|id>"
```

---

### 🐳 Docker (Needed For deploying backend)

```
# Docker must be installed and running:
docker version
```

> 🔗 **Installation help →** https://docs.docker.com/get-docker/

---

### 🔧 Docker Buildx (Needed For deploying backend)

```
# Docker Buildx must be available:
docker buildx version
```

> 🔗 **Installation help →** https://docs.docker.com/build/install-buildx/


---

## 📦 One-Command Setup (macOS)

Install Azure Deployment Tools under `~/tools/az-deploy`, create a global `az-deploy` command, and make it persistent:

Simply copy and run the following block in your terminal:

```bash
curl -s https://raw.githubusercontent.com/Sokrates1989/azure-deployment-guide/main/setup/macos.sh | bash
```

You can then use it from anywhere:

```bash
az-deploy --test   # or: az-deploy
```


---


## 📊 ACA vs. ACI

Quick comparison:

| Aspect               | Azure Container Instances (ACI)        | Azure Container Apps (ACA)                      |
|----------------------|----------------------------------------|-------------------------------------------------|
| **Abstraction Level** | Low                                    | High                                            |
| **Orchestration**     | None                                   | Built-in (Kubernetes-based)                     |
| **Auto-Scaling**      | No (manual/external)                   | Yes (built-in)                                  |
| **Routing/Ingress**   | Manual                                 | Built-in                                        |
| **Dev Focus**         | Quick & easy                           | Full app platform                               |
| **DevOps & CI/CD**    | Minimal                                | Integrated                                      |
| **Best For**          | Short-lived tasks, simple services     | Scalable microservices, modern web apps         |

---

## 🧑‍💻 Usage

### ▶️ Simple Usage

To launch the deployment tool, simply run:

```bash
az-deploy
```

You can run this in any terminal or shell, including the integrated terminal in **VS Code** or other IDEs.

Once started, a step-by-step menu will guide you through the installation or update process of your **Azure Container Apps**.

---


### 🔀 Quick Options

Use the following flags for direct actions:

- `-i` → Install new container apps  
- `-c` → Change or update running container apps  
- `-u` → Update the az-deploy tool itself  

Example:

```bash
az-deploy -i
```

---

### ⚡ Advanced Usage: Fast Mode

If you've previously deployed an ACA setup using this tool, you can reuse your settings via "Fast Mode".

When prompted, simply paste an edited version of your previous summary block. This saves time and avoids re-entering every detail.



### 📄 Usage Guides

- 📦 [Backend Deployment Guide](readmes/backend-deploy.md)  
  ➤ Alles rund um die Bereitstellung von Backend + Reverse Proxy via Azure Container Apps

- 🧪 [Test Deployment Guide](readmes/test-deploy.md)  
  ➤ Für temporäre Test-Setups oder interne Validierung

- 🌐 [Frontend Deployment Guide](readmes/frontend-deploy.md)  
  ➤ Deployment des Frontends inkl. Domain & CDN-Konfiguration

- ⚙️ [Global Setup & Tools](readmes/tool-overview.md)  
  ➤ Wie das CLI-Tool funktioniert und wie du es aktualisierst

---

## 🚀 Summary

✅ **ACA is ideal for modern, scalable applications and microservices**  
✅ **Provides built-in auto-scaling and ingress routing**  
✅ **Significantly differs from ACI in abstraction and DevOps integration**  
✅ **Quick setup with only basic Azure CLI usage required**
