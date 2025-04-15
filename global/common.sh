#!/bin/bash

# === ask: prompt with default value ===
ask() {
  local prompt="$1"
  local default="$2"
  read -rp "$prompt [$default]: " input
  echo "${input:-$default}"
}
