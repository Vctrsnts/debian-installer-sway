#!/bin/bash

# --- Definicion de funciones para mensajes con color ---
# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Funciones de log
log_success() {
  echo -e "${GREEN}=== $1 ===${NC}"
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

# Instalamos aptitude para el triaje de paquetes
sudo apt install -y aptitude

# Eliminamos paquetes conocidos
sudo apt purge -y bluez bluetooth debian-faq debian-reference-common debian-reference-es doc-debian manpages manpages-es nano emacsen-common aspell aspell-es dictionaries-common ispanish ispell wspanish task-spanish laptop-detect
sudo apt -y autoremove

log_info "Abriendo aptitude para revisión manual. Cuando termines, se continuará con la instalación de Git y el repositorio."

sudo aptitude

# --- Verificar si Git está instalado ---
if ! command -v git &> /dev/null; then
  log_success "Git no está instalado. Procediendo a instalarlo..."
  sudo apt install -y git
else
  log_success "Git ya está instalado."
fi

# =======================
# Clonar repositorio desde GitHub
# =======================
REPO_URL="https://github.com/Vctrsnts/debian-installer-sway.git"
CLONE_DIR="$HOME/debian-installer-sway.git"

if [[ ! -d "$CLONE_DIR" ]]; then
  log_success "Clonando repositorio desde GitHub: $REPO_URL"
  git clone "$REPO_URL" "$CLONE_DIR"
  log_success "Repositorio clonado en: $CLONE_DIR"
  log_success "Puedes continuar la instalación ejecutando:"
  echo -e "${GREEN}cd $CLONE_DIR && ./01-instalacio.sh${NC}"
else
  log_success "El repositorio ya existe en: $CLONE_DIR"
  log_success "Si deseas actualizarlo, ejecuta:"
  echo -e "${GREEN}cd $CLONE_DIR && git pull${NC}"
fi

log_success "Se ejecuta la actualización del funcionamiento de los sources"
sudo apt -y modernize-sources

log_success "Eliminamos aplicacion aptitude"
sudo apt purge -y aptitude && sudo apt -y autoremove

exit 0
