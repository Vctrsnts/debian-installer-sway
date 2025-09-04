#!/bin/bash
set -euo pipefail

# --- Definicion de funciones para mensajes con color ---
# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# ===== Variables =====
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

# Funciones
apt_install(){
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends "$@"
}
apt_purge(){
  sudo apt purge -y "$@"
}
log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}
ensure_dirs_user(){
    local dir="$1"
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$dir"
}
mod_fuentes() {
  echo "🔤 Instalación de fuentes adicionales (Inter, Noto Sans)…"
  read -p "¿Instalar fuentes del sistema (Font Awesome, Terminus)? (s/n): " RESP
  [[ "$RESP" == "s" ]] && apt_install fonts-font-awesome fonts-terminus

  echo "🔠 Instalación de Nerd Fonts en el entorno del usuario…"
  read -p "¿Continuar con la instalación de Nerd Fonts? (s/n): " RESP
  [[ "$RESP" != "s" ]] && return 0

  local FONT_DIR="$USER_HOME/.local/share/fonts"
  ensure_dirs_user "$FONT_DIR"

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
    echo -e "\n🔧 Preparando instalación de fuente: $font"
    read -p "¿Instalar '$font'? (s/n): " RESP
    [[ "$RESP" != "s" ]] && continue

    if [[ -d "$FONT_DIR/$font" ]] && find "$FONT_DIR/$font" -type f -name '*.ttf' | grep -q .; then
      echo "✅ Fuente '$font' ya instalada; se omite."
      continue
    fi

    echo "⬇️ Descargando fuente: $font"
    local URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/${font}.zip"
    local ZIP_PATH="/tmp/${font}.zip"

    if ! wget -q --show-progress "$URL" -O "$ZIP_PATH"; then
      echo "⚠️ Fallo al descargar $font desde $URL; se omite."
      continue
    fi

    echo "📁 Instalando en: $FONT_DIR/$font"
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$FONT_DIR/$font"

    if unzip -qqo "$ZIP_PATH" -d "$FONT_DIR/$font"; then
      chown -R "$TARGET_USER:$TARGET_USER" "$FONT_DIR/$font"
      find "$FONT_DIR/$font" -type f ! -iname '*.ttf' ! -iname '*.otf' -delete || true
      echo "✅ Fuente '$font' instalada correctamente."
    else
      echo "⚠️ No se pudo descomprimir '$font'; se omite."
    fi

    rm -f "$ZIP_PATH"
  done

  echo -e "\n🔄 Refrescando caché de fuentes…"
  read -p "¿Actualizar caché de fuentes ahora? (s/n): " RESP
  [[ "$RESP" == "s" ]] && sudo -u "$TARGET_USER" fc-cache -fv "$FONT_DIR" >/dev/null || fc-cache -fv "$FONT_DIR" >/dev/null || true

  echo "✅ Fuentes instaladas y caché actualizada."
}
mod_tema_oscuro() {  
  THEME="Nordic"
  ICON_THEME="Colloid-Dark"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "🖤 Aplicando tema GTK oscuro: $THEME con iconos $ICON_THEME"

  TMP_DIR=$(mktemp -d) || { echo "❌ No se pudo crear directorio temporal"; return 1; }
  ICON_TMP=$(mktemp -d) || { echo "❌ No se pudo crear directorio temporal para iconos"; return 1; }
  trap 'rm -rf "$TMP_DIR" "$ICON_TMP"' EXIT

  mkdir -p "$HOME/.local/share/themes"
  mkdir -p "$HOME/.local/share/icons"

  echo "🔧 Actualizando paquetes e instalando dependencias necesarias..."
  read -p "¿Continuar con la instalación de dependencias? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  if ! sudo apt update && sudo apt install -y gtk2-engines-murrine git; then
      echo "❌ Error instalando dependencias"
      return 1
  fi

  echo "🎨 Preparando instalación del tema Nordic..."
  read -p "¿Instalar tema Nordic en ~/.local/share/themes? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  THEME_DEST="$HOME/.local/share/themes/Nordic"
  if [[ ! -d "$THEME_DEST" ]]; then
      git clone https://github.com/EliverLara/Nordic.git "$TMP_DIR/Nordic" &&
      mkdir -p "$THEME_DEST" &&
      cp -r "$TMP_DIR/Nordic"/* "$THEME_DEST/" &&
      echo "✅ Tema Nordic instalado en el directorio del usuario"
  else
      echo "ℹ️ Tema Nordic ya está instalado en el directorio del usuario"
  fi

  echo "🧩 Preparando instalación de iconos Tela-Dark..."
  read -p "¿Instalar iconos Tela-Dark? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  if [[ ! -d "$HOME/.local/share/icons/Tela-Dark" ]]; then
      git clone https://github.com/vinceliuice/Tela-icon-theme.git "$ICON_TMP/Tela" &&
      cd "$ICON_TMP/Tela" &&
      ./install.sh -d "$HOME/.local/share/icons" -c nord &&
      echo "✅ Iconos Tela-Dark instalados"
  else
      echo "ℹ️ Iconos Tela-Dark ya están instalados"
  fi

  echo "🧩 Preparando instalación de iconos Colloid (nord)..."
  read -p "¿Instalar iconos Colloid nord? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  COLLOID_REPO="https://github.com/vinceliuice/Colloid-icon-theme.git"
  COLLOID_DIR="$ICON_TMP/Colloid"
  VARIANT="nord"
  THEME_NAME="Colloid-${VARIANT^}-Dark"
  ICON_PATH="$HOME/.local/share/icons/$THEME_NAME"

  [[ -d "$COLLOID_DIR" ]] || git clone "$COLLOID_REPO" "$COLLOID_DIR"
  cd "$COLLOID_DIR" || return 1

  if [[ ! -d "$ICON_PATH" ]]; then
      ./install.sh -d "$HOME/.local/share/icons" -s "$VARIANT"
      echo "✅ Iconos Colloid instalados: $VARIANT"
  else
      echo "ℹ️ Iconos Colloid ya instalados: $VARIANT"
  fi

  echo "🧩 Preparando instalación de iconos Nordzy (default dark)..."
  read -p "¿Instalar iconos Nordzy? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  NORDZY_REPO="https://github.com/MolassesLover/Nordzy-icon.git"
  NORDZY_DIR="$ICON_TMP/Nordzy"
  THEME="default"
  COLOR="dark"
  THEME_NAME="Nordzy"
  ICON_DEST="$HOME/.local/share/icons/$THEME_NAME"

  [[ -d "$NORDZY_DIR" ]] || git clone "$NORDZY_REPO" "$NORDZY_DIR"
  cd "$NORDZY_DIR" || exit 1

  if [[ ! -d "$ICON_DEST" ]]; then
      ./install.sh \
          --dest "$HOME/.local/share/icons" \
          --name "$THEME_NAME" \
          --theme "$THEME" \
          --color "$COLOR"
      echo "✅ Iconos Nordzy instalados como '$THEME_NAME'"
  else
      echo "ℹ️ Iconos Nordzy ya instalados como '$THEME_NAME'"
  fi

  echo "🎛️ Aplicando configuración GTK con gsettings..."
  read -p "¿Aplicar configuración GTK e iconos ahora? (s/n): " RESP
  [[ "$RESP" == "s" ]] || return 0

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  gsettings set org.gnome.desktop.interface gtk-theme "Nordic" || true
  gsettings set org.gnome.desktop.interface icon-theme "Nordzy" || true
  gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_cursors' || true
  gsettings set org.gnome.desktop.interface font-name 'RobotoMon Nerd Font Medium 11' || true

  echo -e "\n✅ Instalación de temas e iconos completada con confirmaciones paso a paso"
}

# INICI DE APLICACIO

log_success "Procedim a la instalacio de paquets suplementaris"
# instalacion de aplicaciones externas
pkgs=(
  btm
  thunar thunar-volman
  gvfs gvfs-backends 
  breeze-cursor-theme
  greetd gtkgreet
  foot wofi
  libglib2.0-bin
)

apt_install "${pkgs[@]}"

log_success "Procedim a realitzar la configuració de greetd i gtkgreet"
sudo cp $HOME/debian-installer-sway/custom-configs/greetd/* /etc/greetd/
sudo chmod go+r /etc/greetd
sudo systemctl enable greetd

echo ""
log_success "Procedim a copiar els fitxers de configuració del usuari"
echo ""
SRC="$HOME/debian-installer-sway/custom-configs"
DEST_CONFIG="$HOME/.config"
DEST_HOME="$HOME"

mkdir -p "$DEST_CONFIG"

for item in "$SRC"/*; do
  name=$(basename "$item")

  # Saltar greetd
  if [ "$name" = "greetd" ]; then
    echo "⏭️  Ignorando directorio '$name'"
    continue
  fi

  if [ -d "$item" ]; then
    # Es un directorio → copiar dentro de ~/.config con su nombre
    cp -r "$item" "$DEST_CONFIG/$name" && echo "📁 Directorio '$name' copiado a $DEST_CONFIG/$name"
  elif [ -f "$item" ]; then
    # Es un archivo → verificar si debe ir con punto
    case "$name" in
      bashrc|gtkrc-2.0) target=".$name" ;;
      *) target="$name" ;;
    esac

    cp "$item" "$DEST_HOME/$target" && echo "📄 Archivo '$name' copiado como '$target' a $DEST_HOME"
  fi
done

log_success "Procedim a copia el wallpaper de gtkgreet"
sudo mkdir -p /usr/share/backgrounds
sudo mv $HOME/.config/backgrounds/login.jpg /usr/share/backgrounds/login.jpg
sudo chmod 644 /usr/share/backgrounds/login.jpg
sudo chown -R root:root /usr/share/backgrounds/login.jpg
log_success "Instalacio de les fonts, estil obscurs i GTK"
mod_fuentes
mod_tema_oscuro
echo ""
log_success "Desinstalem paquets que ja no es faran servir"
pkgs=(
  git
)
apt_purge "${pkgs[@]}"
sudo apt -y autoremove

log_success "Procedim a moure iconos Adwaita"
sudo mv /usr/share/icons/Adwaita /usr/share/icons/Adwaita.bak
