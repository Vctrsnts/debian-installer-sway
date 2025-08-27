#!/bin/bash
set -euo pipefail

# ===== Colores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ===== Variables =====
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

# ===== Funciones de logging =====
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
log_warn() {
  echo -e "${YELLOW}"
  echo "=========================================="
  echo -e "⚠ $1 ⚠"
  echo "=========================================="
  echo -e "${NC}"
}

# ===== Auxiliares =====
apt_install() {
  sudo apt-get install -y --no-install-recommends "$@"
}
ensure_dirs_user() {
  local dir="$1"
  install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$dir"
}

# ===== Funciones principales =====
mod_terminal() {
  log_info "Añadiendo el repositorio de WezTerm e instalando..."

  # Clave GPG
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

  sudo apt-get update -y
  apt_install wezterm

  log_success "🎉 WezTerm instalado correctamente."
}

mod_fuentes() {
  log_info "Instalación de fuentes adicionales..."
  apt_install fonts-recommended fonts-font-awesome fonts-terminus unzip

  local FONT_DIR="$USER_HOME/.local/share/fonts"
  ensure_dirs_user "$FONT_DIR"

  local fonts=(CascadiaCode FiraCode Hack Inconsolata JetBrainsMono Meslo Mononoki RobotoMono SourceCodePro UbuntuMono)

  for font in "${fonts[@]}"; do
    if [[ -d "$FONT_DIR/$font" ]] && find "$FONT_DIR/$font" -type f -name '*.ttf' | grep -q .; then
      log_info "Fuente '$font' ya instalada; omitiendo."
      continue
    fi
    log_info "Descargando e instalando: $font"
    local URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/${font}.zip"
    local ZIP_PATH="/tmp/${font}.zip"

    if ! wget -q --show-progress "$URL" -O "$ZIP_PATH"; then
      log_warn "Fallo al descargar $font desde $URL; se omite."
      continue
    fi

    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$FONT_DIR/$font"

    if unzip -qqo "$ZIP_PATH" -d "$FONT_DIR/$font"; then
      chown -R "$TARGET_USER:$TARGET_USER" "$FONT_DIR/$font"
      find "$FONT_DIR/$font" -type f ! -iname '*.ttf' ! -iname '*.otf' -delete || true
      log_success "Fuente $font instalada."
    else
      log_warn "No se pudo descomprimir $font; se omite."
    fi
    rm -f "$ZIP_PATH"
  done

  runuser -u "$TARGET_USER" -- fc-cache -fv "$FONT_DIR" >/dev/null 2>&1 || true
  log_success "Fuentes instaladas y caché refrescada."
}

# ===== Ejecución principal =====
log_success "Iniciando la instalación de aplicaciones esenciales para Sway en Debian Unstable..."

sudo apt-get update -y
sudo apt-get upgrade -y

pkgs=(
  sway swaybg waybar swaylock swayidle sway-notification-center
  wayland-protocols xwayland rofi lxappearance pavucontrol
  wireplumber alsa-utils polkitd lxpolkit
  brightnessctl grim slurp clipman wl-clipboard
  avahi-daemon acpi acpid btop greetd gtkgreet curl gpg unzip
  eza pulseaudio pulseaudio-utils
)
apt_install "${pkgs[@]}"

sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

log_info "Configurando Greetd y Gtkgreet..."
cat << EOF | sudo tee /etc/greetd/config.toml > /dev/null
[terminal]
vt = 7

[default_session]
user = "greeter"
command = "gtkgreet"
EOF

cat << EOF | sudo tee /etc/greetd/gtkgreet.toml > /dev/null
[greeter]
background = "/ruta/a/tu/imagen.jpg"

[default_session]
command = "sway"
EOF

sudo systemctl enable greetd.service

# ===== Llamadas a funciones =====
mod_terminal
mod_fuentes

echo "✅ Instalación completada. Configura Sway según las indicaciones finales."
