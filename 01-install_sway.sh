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
  echo -e "${BLUE}"
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
mod_fuentes(){
  log_info "Instalación de fuentes adicionales (Inter, Noto Sans)…"
  apt_install fonts-font-awesome fonts-terminus
  
  log_info "Instalación de Nerd Fonts…"
  local FONT_DIR="$USER_HOME/.local/share/fonts"
  ensure_dirs_user "$FONT_DIR"

  # Selección de familias Nerd Fonts
  local fonts=(
    CascadiaCode
    FiraCode
    Hack
    Inconsolata
    JetBrainsMono
    Meslo
    Mononoki
    RobotoMono
    SourceCodePro
    UbuntuMono
  )

  for font in "${fonts[@]}"; do
    if [[ -d "$FONT_DIR/$font" ]] && find "$FONT_DIR/$font" -type f -name '*.ttf' | grep -q .; then
      log_info "Fuente '$font' ya instalada; omitiendo."
      continue
    fi
    log_info "Descargando e instalando: $font"
    local URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/${font}.zip"
    local ZIP_PATH="/tmp/${font}.zip"

    # Descarga
    if ! wget -q --show-progress "$URL" -O "$ZIP_PATH"; then
      log_warn "Fallo al descargar $font desde $URL; se omite."
      continue
    fi

    # Carpeta destino por fuente
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$FONT_DIR/$font"

    # Descomprimir y limpiar
    if unzip -qqo "$ZIP_PATH" -d "$FONT_DIR/$font"; then
      chown -R "$TARGET_USER:$TARGET_USER" "$FONT_DIR/$font"
      find "$FONT_DIR/$font" -type f ! -iname '*.ttf' ! -iname '*.otf' -delete || true
      log_success "Fuente $font instalada."
    else
      log_warn "No se pudo descomprimir $font; se omite."
    fi
    rm -f "$ZIP_PATH"
  done

  # Refrescar caché de fuentes
  sudo -u "$TARGET_USER" fc-cache -fv "$FONT_DIR" >/dev/null || fc-cache -fv "$FONT_DIR" >/dev/null || true
  log_success "Fuentes instaladas y caché refrescada."
}
#!/usr/bin/env bash
set -euo pipefail

#!/usr/bin/env bash
set -euo pipefail

mod_tema_oscuro() {
  THEME="Nordic"
  ICON_THEME="Colloid-Dark"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "🖤 Aplicando tema GTK oscuro: $THEME con iconos $ICON_THEME"

  TMP_DIR=$(mktemp -d) || { echo "❌ No se pudo crear directorio temporal"; return 1; }
  ICON_TMP=$(mktemp -d) || { echo "❌ No se pudo crear directorio temporal para iconos"; return 1; }
  trap 'rm -rf "$TMP_DIR" "$ICON_TMP"' EXIT

  # Dependencias
  if ! sudo apt update && sudo apt install -y gtk2-engines-murrine git; then
      echo "❌ Error instalando dependencias"
      return 1
  fi

  # Tema Nordic
  if [[ ! -d "/usr/share/themes/Nordic" ]]; then
      git clone https://github.com/EliverLara/Nordic.git "$TMP_DIR/Nordic" &&
      sudo mkdir -p /usr/share/themes/Nordic &&
      sudo cp -r "$TMP_DIR/Nordic"/* /usr/share/themes/Nordic/ &&
      echo "🎨 Tema Nordic instalado"
  else
      echo "🎨 Tema Nordic ya está instalado"
  fi

  # Iconos
  mkdir -p "$HOME/.local/share/icons"

  # Tela-Dark
  if [[ ! -d "$HOME/.local/share/icons/Tela-Dark" ]]; then
      git clone https://github.com/vinceliuice/Tela-icon-theme.git "$ICON_TMP/Tela" &&
      cd "$ICON_TMP/Tela" &&
      ./install.sh -d "$HOME/.local/share/icons" -c nord &&
      echo "🧩 Iconos Tela-Dark instalados"
  else
      echo "🧩 Iconos Tela-Dark ya están instalados"
  fi

  # Colloid nord
  COLLOID_REPO="https://github.com/vinceliuice/Colloid-icon-theme.git"
  COLLOID_DIR="$ICON_TMP/Colloid"
  VARIANT="nord"
  THEME_NAME="Colloid-${VARIANT^}-Dark"
  ICON_PATH="$HOME/.local/share/icons/$THEME_NAME"

  [[ -d "$COLLOID_DIR" ]] || git clone "$COLLOID_REPO" "$COLLOID_DIR"
  cd "$COLLOID_DIR" || return 1

  if [[ ! -d "$ICON_PATH" ]]; then
      ./install.sh -d "$HOME/.local/share/icons" -s "$VARIANT"
      echo "🧩 Iconos Colloid instalados: $VARIANT"
  else
      echo "🧩 Iconos Colloid ya instalados: $VARIANT"
  fi


  # Aplicar configuración GTK vía gsettings (rápido)
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME}-Dark" || true
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
  gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' || true
  gsettings set org.gnome.desktop.interface font-name 'Sans 10' || true

  echo "✅ Instalación de temas e iconos completada"
}

mod_gtk() {
  echo "🎨 Aplicando configuración GTK:"
  echo "  Tema GTK: Nordic-Dark"
  echo "  Iconos:   Colloid-Nord-Dark"
  echo "  Fuente:   Sans 10"
  echo "  Cursor:   Adwaita 24px"

  # GTK3
  mkdir -p "$HOME/.config/gtk-3.0"
  cat << EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Nordic-Dark
gtk-icon-theme-name=Colloid-Nord-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintmedium"
gtk-xft-rgba="rgb"
gtk-application-prefer-dark-theme=1
EOF

  # GTK2
  cat << EOF > "$HOME/.gtkrc-2.0"
gtk-theme-name="Nordic-Dark"
gtk-icon-theme-name="Colloid-Nord-Dark"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintmedium"
gtk-xft-rgba="rgb"
EOF

  echo "✅ Configuración GTK aplicada"
}
mod_lightdm_greeter() {
  local CONF_FILE="/etc/lightdm/lightdm-gtk-greeter.conf.d/99-custom.conf"

  echo "⚙ Configurando LightDM GTK Greeter con fondo, tema e iconos..."

  if [[ $EUID -ne 0 ]]; then
      echo "❌ Esta función debe ejecutarse como root (usa sudo)."
      return 1
  fi

  sudo mkdir -p "$(dirname "$CONF_FILE")"

  cat << EOF | sudo tee "$CONF_FILE" > /dev/null
[greeter]
background = /usr/share/backgrounds/login.jpg
theme-name = Nordic-Dark
icon-theme-name = Colloid-Nord-Dark
font-name = Sans 11
xft-antialias = true
xft-hintstyle = hintmedium
EOF

  echo "✅ Configuración de LightDM GTK Greeter aplicada"
  echo "💡 Asegúrate de que la imagen exista en /usr/share/backgrounds/login.jpg"
}


log_success "Iniciando la instalación de las aplicaciones esenciales para Sway en Debian Unstable..."

# Actualizar el índice de paquetes y el sistema
log_success "Actualizando el sistema..."

sudo apt update
sudo apt upgrade -y

# Instalar todos los paquetes necesarios en una sola línea
# Incluye los componentes de Sway, utilidades del sistema, audio, red, y herramientas de usuario
log_success "Instalando todos los paquetes necesarios..."

pkgs=(
  sway swaybg waybar swaylock swayidle 
  sway-notification-center 
  wayland-protocols xwayland
  rofi lxappearance pavucontrol
  wireplumber alsa-utils 
  polkitd lxpolkit eza git
  grim slurp pulseaudio-utils
  clipman wl-clipboard 
  avahi-daemon btop xterm
  acpi acpid curl gpg unzip pulseaudio
  libpam0g libseat1 fastfetch
  lightdm lightdm-gtk-greeter 
)

apt_install "${pkgs[@]}"

sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

# Verificar si el archivo de sesión de Sway existe
if [ ! -f "/usr/share/wayland-sessions/sway.desktop" ]; then
    log_error "El archivo 'sway.desktop' no se encontró. Asegúrate de que el paquete 'sway' esté instalado y que los archivos de sesión se hayan generado correctamente."
    exit 1
fi

mod_terminal
mod_fuentes
mod_tema_oscuro
mod_gtk
mod_lightdm_greeter

echo "Instalación completada. Se han instalado todos los paquetes necesarios."
echo ""
echo "Recuerda que para la configuración, necesitas:"
echo "1. Añadir los siguientes comandos a tu archivo de configuración de Sway (~/.config/sway/config):"
echo "   exec lxpolkit"
echo "   exec --no-startup-id clipman"
echo "   exec sway-notification-center"
echo "2. Configurar una combinación de teclas para rofi, por ejemplo: bindsym $mod+d exec rofi -show drun"
echo "3. Para establecer un fondo de pantalla, añade la siguiente línea a tu archivo de configuración de Sway, reemplazando la ruta con la de tu imagen:"
echo "   output * bg /ruta/a/tu/imagen.jpg fill"
echo ""
echo "Información sobre los temas:"
echo "Los temas de iconos 'Colloid Dark' y de apariencia 'Nordic' no se encuentran en los repositorios de Debian. Deberás descargarlos e instalarlos manualmente."
echo ""
echo "Una vez que se ha finalizado la instalación y has ejecutado la instrucción modules/theme_dark/install_theme.sh"
echo "Puedes ejecutar lo siguiente, para copiar el fondo de pantalla que se usara para nwg-hello"
echo "sudo mv /home/"$USER_HOME"/.config/background/login.jpg /usr/share/backgrounds/login.jpg"
echo "sudo chmod 644 /usr/share/backgrounds/login.jpg"
echo ""
