#!/bin/bash

# --- Definicion de funciones para mensajes con color ---
# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Funciones de log
log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}


# =======================
# Descarreguem el ZIP que conte el instalado
# =======================
# Nombre del repositorio en formato usuario/repositorio
log_success "Iniciem la descarrega dels script"
REPO="Vctrsnts/debian-installer-sway"
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ZIP_URL="https://github.com/$REPO/archive/refs/tags/$LATEST_TAG.zip"
ZIP_FILE="debian-installer-sway.zip"
TARGET_FOLDER="debian-installer-sway"

# wget https://github.com/Vctrsnts/debian-installer-sway/archive/refs/tags/v20250827205721.zip

# Descargar el ZIP con nombre personalizado
wget -O "$ZIP_FILE" "$ZIP_URL"

log_success "Finalitzacio de la descarrega dels script"

exit 0
