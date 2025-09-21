#!/bin/bash
set -euo pipefail
# Este script instala los componentes esenciales para un entorno Sway funcional y minimalista
# en Debian Unstable, con todos los paquetes en una única sección de instalación.

# ===== Colores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ===== Variables =====
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

# Función para manejar errores
log_error() {
  echo -e "${RED}"
  echo "=========================================="
  echo -e "!!! Ha ocurrido un fallo en el script. Saliendo... !!!"
  echo "=========================================="
  echo -e "${NC}"
  exit 1
}
log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}
log_info() {
  echo -e "${YELLOW}"
  echo "=========================================="
  echo -e "--- $1 ---"
  echo "=========================================="
  echo -e "${NC}"
}
apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends "$@"
}
ensure_dirs_user(){
    local dir="$1"
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$dir"
}
mod_terminal(){
  log_info "Añadiendo el repositorio de WezTerm e instalando..."

  # Descargar la clave GPG
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg

  # Agregar el repositorio
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

  # Instalar WezTerm
  apt_install wezterm

  log_success "🎉 WezTerm instalado correctamente."
}

# Actualizar el índice de paquetes y el sistema
log_success "Actualizando el sistema..."
sudo apt update

log_success "Iniciando la instalación de las aplicaciones esenciales para Sway en Debian Unstable..."
sudo apt upgrade -y

# Instalar todos los paquetes necesarios en una sola línea
log_success "Instalando todos los paquetes necesarios..."

pkgs=(
  sway swaybg waybar swaylock swayidle
  mako-notifier wayland-protocols xwayland
  wofi polkitd lxpolkit git
  nwg-look greetd gtkgreet
  pcmanfm gvfs gvfs-backends udisks2
  clipman wl-clipboard
  pulseaudio pulseaudio-utils pamixer
  xdg-user-dirs xdg-utils pavucontrol
  curl gpg unzip
  libpam0g libseat1 fastfetch
  acpi acpid eza 
  gsettings-desktop-schemas
)

apt_install "${pkgs[@]}"

log_success "Activant servei acpid"
sudo systemctl enable acpid

# Verificar si el archivo de sesión de Sway existe
if [ ! -f "/usr/share/wayland-sessions/sway.desktop" ]; then
    log_error "El archivo 'sway.desktop' no se encontró. Asegúrate de que el paquete 'sway' esté instalado y que los archivos de sesión se hayan generado correctamente."
    exit 1
fi

mod_terminal

log_success "Actualem .bashrc"
cp $HOME/debian-installer-sway/custom-configs/bashrc $HOME/.bashrc
source $HOME/.bashrc

log_success "Instalación completada. Se han instalado todos los paquetes necesarios."
echo ""
echo "Recuerda que para la configuración, necesitas:"
echo "1. Añadir los siguientes comandos a tu archivo de configuración de Sway (~/.config/sway/config):"
echo "   exec lxpolkit"
echo "   exec --no-startup-id clipman"
echo "   exec mako"
echo ""
log_success "Per si de cas, actualitzar .bashrc a traves de source \$HOME/.bashrc"
echo ""
log_success "Arribats aqui, ja pots executa script 02-post-install.sh."
echo ""
