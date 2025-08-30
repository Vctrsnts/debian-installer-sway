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
  sway-notification-center 
  wayland-protocols xwayland
  rofi lxappearance 
  wireplumber alsa-utils 
  polkitd lxpolkit git
  grim slurp clipman wl-clipboard 
  pulseaudio pulseaudio-utils pamixer
  xdg-user-dirs xdg-utils pavucontrol
  curl gpg unzip wl-clipboard wlogout
  libpam0g libseat1 fastfetch
  avahi-daemon acpi acpid
)

apt_install "${pkgs[@]}"

log_success "Activant servei avahi-daemon"
sudo systemctl enable avahi-daemon

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
echo "   exec sway-notification-center"
echo "2. Configurar una combinación de teclas para rofi, por ejemplo: bindsym \$mod+d exec rofi -show drun"
echo "3. Para establecer un fondo de pantalla, añade la siguiente línea a tu archivo de configuración de Sway, reemplazando la ruta con la de tu imagen:"
echo "   output * bg /ruta/a/tu/imagen.jpg fill"
echo ""
log_success "Per si de cas, actualitzar .bashrc a traves de source \$HOME/.bashrc"
echo ""
echo ""
log_success "Procedim a copiar els fitxers de configuració del usuari"
echo ""
SRC="$HOME/debian-installer-sway/custom-configs"
DEST_CONFIG="$HOME/.config"
DEST_HOME="$HOME"

# Recorremos todos los elementos dentro de custom-configs
for item in "$SRC"/*; do
  name=$(basename "$item")
  
  if [ -d "$item" ]; then
    # Es un directorio → copiar a ~/.config
    cp -r "$item" "$DEST_CONFIG" && echo "📁 Directorio '$name' copiado a $DEST_CONFIG"
  elif [ -f "$item" ]; then
    # Es un archivo → verificar si debe ir con punto
    case "$name" in
      bashrc) target=".$name" ;;
      gtkrc-2.0) target=".$name" ;;
      *) target="$name" ;;
    esac

    cp "$item" "$DEST_HOME/$target" && echo "📄 Archivo '$name' copiado como '$target' a $DEST_HOME"
  fi
done

echo ""
log_success "Arribats aqui, ja pots executa script 02-post-install.sh."
echo ""
