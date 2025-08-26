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

# Este script prepara el sistema para la transicion a Debian Unstable.
# Se recomienda ejecutarlo como root o con sudo.

log_success "Iniciando la preparacion del sistema para Debian Unstable ---"

# --- Seccion 1: Preparacion del sistema ---

# 1. Desactivar la instalacion de paquetes sugeridos y recomendados
log_success "Configurando APT para evitar la instalacion de paquetes recomendados y sugeridos..."
echo 'APT::Install-Recommends "false";' | sudo tee /etc/apt/apt.conf.d/99-no-recommends.conf
echo 'APT::Install-Suggests "false";' | sudo tee -a /etc/apt/apt.conf.d/99-no-recommends.conf

# 2. Instalar localepurge
log_success "Instalando localepurge para limpiar idiomas no deseados..."
sudo apt install -y localepurge

# 3. Preguntar por la version de Debian actual y modificar sources.list
read -p "Por favor, introduce el nombre de la version actual de Debian (ej. 'forky'): " current_version
log_success "Modificando /etc/apt/sources.list para apuntar a 'testing'..."
sudo sed -i "s/$current_version/testing/g" /etc/apt/sources.list

log_success "Actualizando e instalando paquetes del repositorio 'testing'..."
sudo apt -y update
sudo apt -y upgrade

# 4. Modificar sources.list para usar 'unstable' (sid) y actualizar
log_success "Modificando /etc/apt/sources.list para apuntar a 'unstable' (sid)..."
# Reemplaza 'testing' por 'unstable'.
sudo sed -i 's/testing/unstable/g' /etc/apt/sources.list

log_success "Actualizando e instalando paquetes del repositorio 'unstable' (full-upgrade)..."
log_success "¡ADVERTENCIA! El siguiente paso podría eliminar paquetes. Revisa la salida de la consola cuidadosamente antes de confirmar."
# Nota: Se ha quitado el flag -y para que el usuario pueda revisar los cambios.
sudo apt -y update
sudo apt -y full-upgrade

# Eliminamos paquetes conocidos
local pkgs=(
  bluez bluetooth 
  debian-faq debian-reference-common 
  debian-reference-es 
  doc-debian manpages 
  manpages-es nano 
  emacsen-common aspell 
  aspell-es dictionaries-common 
  ispanish ispell 
  wspanish task-spanish 
  laptop-detect
  apt-listchanges reportbug python3-reportbug
  python3-apt distro-info-data iso-codes
  python3-requests python3-debian
  python3-charset-normalizer
  python3-urllib3 python3-idna
  lsb-release python-apt-common
  python3-certifi python3-chardet
  python3-debconf python3-debianbts
  python3 libpython3-stdlib python3.13
  libpython3.13-stdlib python3-minimal
  python3.13-minimal libpython3.13-minimal
)

sudo apt purge -y "${pkgs[@]}"
sudo apt -y autoremove

log_info "Abriendo aptitude para revisión manual. Cuando termines, se continuará con la instalación de Git y el repositorio."

# Instalamos aptitude para el triaje de paquetes
sudo apt install -y aptitude

sudo aptitude

# --- Verificar si Git está instalado ---
#if ! command -v git &> /dev/null; then
#  log_success "Git no está instalado. Procediendo a instalarlo..."
#  sudo apt install -y git
#else
#  log_success "Git ya está instalado."
#fi

sudo apt install -y curl unzip

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

# Descargar el ZIP con nombre personalizado
wget -O "$ZIP_FILE" "$ZIP_URL"

# Descomprimir en carpeta temporal
TEMP_FOLDER="temp_extract"
mkdir -p "$TEMP_FOLDER"
unzip "$ZIP_FILE" -d "$TEMP_FOLDER"

# Detectar la carpeta interna (la única que hay dentro del ZIP)
INNER_FOLDER=$(find "$TEMP_FOLDER" -mindepth 1 -maxdepth 1 -type d)

# Crear carpeta destino y mover contenido
mkdir -p "$TARGET_FOLDER"
mv "$INNER_FOLDER"/* "$TARGET_FOLDER"

# Limpiar
rm -r "$TEMP_FOLDER"
rm "$ZIP_FILE"

log_success "Finalitzacio de la descarrega dels script"

log_success "Se ejecuta la actualización del funcionamiento de los sources"
sudo apt -y modernize-sources

log_success "Eliminamos aplicacion aptitude"
sudo apt purge -y aptitude w3m && sudo apt -y autoremove

exit 0
