# 🚀 Azure Deployment Guide – Focus: Azure Container Apps (ACA)

## 📜 Description

This guide walks you through deploying container-based applications on Azure, with a primary focus on **Azure Container Apps (ACA)**. It also highlights the differences between **Azure Container Instances (ACI)** and ACA to help you choose the right tool for the job.

---

## 📚 Table of Contents

1. [📖 Overview](#-overview)  
2. [📦 One-Command Setup (macOS)](#-one-command-setup-macos)  
3. [⚙️ Prerequisites](#️-prerequisites)  
4. [📊 ACA vs. ACI](#-aca-vs-aci)  
5. [🚀 Getting Started with ACA](#-getting-started-with-aca)  
6. [🔗 Further Guides](#-further-guides)  
7. [🚀 Summary](#-summary)  

---

## 📖 Overview

Azure offers multiple ways to run containers. **ACI** is great for simple and short-lived workloads, while **ACA** provides a powerful, scalable platform for modern applications and microservices.

This guide focuses on ACA as the long-term solution for scalable, production-grade deployments.  
To make onboarding easy, we provide a **single shell script** that:

- Automatically installs the tooling under `~/tools/az-deploy`
- Sets up a globally accessible command: `az-deploy`
- Launches an interactive CLI assistant to help you deploy test containers and more

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

## ⚙️ Prerequisites

Make sure you have the following setup before continuing:

```bash
# Azure CLI must be installed:
# Installation help → https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
az version

# Log in to Azure:
az login

# Select your subscription:
az account set --subscription "<name|id>"
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

## 🚀 Getting Started with ACA

:::info
This section will later link to more specific guides (test container, backend and frontend templates).
:::

Example: Creating a basic ACA environment

```bash
# Create a resource group
az group create --name rg-demo-aca --location westeurope

# Create a Container App Environment
az containerapp env create \
  --name demo-env \
  --resource-group rg-demo-aca \
  --location westeurope
```

---

## 🔗 Further Guides

Coming soon:

- [🔍 Test Container App Deployment (via `az login`)](#)
- [🛠️ Backend Template Deployment Guide](#)
- [🎨 Frontend Template Deployment Guide](#)

---

## 🚀 Summary

✅ **ACA is ideal for modern, scalable applications and microservices**  
✅ **Provides built-in auto-scaling and ingress routing**  
✅ **Significantly differs from ACI in abstraction and DevOps integration**  
✅ **Quick setup with only basic Azure CLI usage required**
