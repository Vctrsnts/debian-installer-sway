#!/bin/bash
set -euo pipefail

# --- Definicion de funciones para mensajes con color ---
# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

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

mod_fuentes(){
  log_success "Instalación de fuentes adicionales (Inter, Noto Sans)…"
  apt_install fonts-font-awesome fonts-terminus

  log_success "Instalación de Nerd Fonts…"
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
      log_success "Fuente '$font' ya instalada; omitiendo."
      continue
    fi
    log_success "Descargando e instalando: $font"
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
  
  # Nordzy default dark (nombre estándar)
  ICON_TMP="${ICON_TMP:-/tmp/icons}"

  NORDZY_REPO="https://github.com/MolassesLover/Nordzy-icon.git"
  NORDZY_DIR="$ICON_TMP/Nordzy"
  THEME="default"
  COLOR="dark"
  THEME_NAME="Nordzy"  # nombre estándar por defecto
  ICON_DEST="$HOME/.local/share/icons/$THEME_NAME"

  # Clonar si no existe
  [[ -d "$NORDZY_DIR" ]] || git clone "$NORDZY_REPO" "$NORDZY_DIR"
  cd "$NORDZY_DIR" || exit 1

  # Crear destino si no existe
  mkdir -p "$HOME/.local/share/icons"

  # Instalar si no está ya presente
  if [[ ! -d "$ICON_DEST" ]]; then
      ./install.sh \
          --dest "$HOME/.local/share/icons" \
          --name "$THEME_NAME" \
          --theme "$THEME" \
          --color "$COLOR"
      echo "🧩 Iconos Nordzy instalados: $THEME ($COLOR) como '$THEME_NAME'"
  else
      echo "🧩 Iconos Nordzy ya instalados como '$THEME_NAME' (puede contener otras variantes)"
  fi

  # Aplicar configuración GTK vía gsettings (rápido)
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME}-Dark" || true
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
  gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' || true
  gsettings set org.gnome.desktop.interface font-name 'Sans 10' || true

  echo "✅ Instalación de temas e iconos completada"
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
  foot
)

apt_install "${pkgs[@]}"

# cd $HOME/debian-installer-sway/custom-configs/greetd
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
