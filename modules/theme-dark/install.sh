#!/usr/bin/env bash
set -e

# Detectar el directorio raíz del proyecto (2 niveles arriba)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONF_FILE="$ROOT_DIR/modules.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar configuración
echo "🔍 Buscando configuración en: $CONF_FILE"
if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
    echo "✅ Configuración cargada desde modules.conf"
else
    echo "❌ No se encontró modules.conf. Abortando..."
    exit 1
fi

# Verificar si se debe aplicar tema oscuro
if [[ "$THEME_DARK" != "YES" ]]; then
    echo "🎨 Tema oscuro desactivado en configuración. Saliendo..."
    exit 0
fi

# Variables de configuración
THEME="${THEME_DARK_NAME:-Materia-dark}"
ICON_THEME="${ICON_DARK_NAME:-Papirus-Dark}"

echo "🖤 Aplicando tema GTK oscuro: $THEME con iconos $ICON_THEME"

# Crear directorio temporal
TMP_DIR=$(mktemp -d)

# Instalar dependencias necesarias
sudo apt update
sudo apt install -y nwg-look gtk2-engines-murrine unzip

# Instalar tema GTK
case "$THEME" in
  "Materia-dark")
    if [[ ! -d "/usr/share/themes/Materia-dark" ]]; then
      git clone https://github.com/nana-4/materia-theme.git "$TMP_DIR/Materia"
      sudo mkdir -p /usr/share/themes/Materia-dark
      sudo cp -r "$TMP_DIR/Materia/Materia-dark"/* /usr/share/themes/Materia-dark/
      echo "🎨 Tema Materia-dark instalado"
    else
      echo "🎨 Tema Materia-dark ya está instalado"
    fi
    ;;
  "Nordic")
    if [[ ! -d "/usr/share/themes/Nordic" ]]; then
      git clone https://github.com/EliverLara/Nordic.git "$TMP_DIR/Nordic"
      sudo mkdir -p /usr/share/themes/Nordic
      sudo cp -r "$TMP_DIR/Nordic"/* /usr/share/themes/Nordic/
      echo "🎨 Tema Nordic instalado"
    else
      echo "🎨 Tema Nordic ya está instalado"
    fi
    ;;
  "Dracula")
    if [[ ! -d "/usr/share/themes/Dracula" ]]; then
      git clone https://github.com/dracula/gtk.git "$TMP_DIR/Dracula"
      sudo mkdir -p /usr/share/themes/Dracula
      sudo cp -r "$TMP_DIR/Dracula"/* /usr/share/themes/Dracula/
      echo "🎨 Tema Dracula instalado"
    else
      echo "🎨 Tema Dracula ya está instalado"
    fi
    ;;
  *)
    echo "❌ Tema no soportado: $THEME"
    exit 1
    ;;
esac

# Asegurar directorio de iconos local
mkdir -p "$HOME/.local/share/icons"

# Instalar iconos
case "$ICON_THEME" in
  "Papirus-Dark")
    if [[ ! -d "$HOME/.local/share/icons/Papirus-Dark" ]]; then
      sudo apt install -y papirus-icon-theme
      echo "🧩 Iconos Papirus-Dark instalados (modo sistema)"
    else
      echo "🧩 Iconos Papirus-Dark ya están instalados"
    fi
    ;;
  "Tela-Dark")
    if [[ ! -d "$HOME/.local/share/icons/Tela-Dark" ]]; then
      git clone https://github.com/vinceliuice/Tela-icon-theme.git "$TMP_DIR/Tela"
      cd "$TMP_DIR/Tela" && ./install.sh -d "$HOME/.local/share/icons" -c dark
      echo "🧩 Iconos Tela-Dark instalados en modo usuario"
    else
      echo "🧩 Iconos Tela-Dark ya están instalados"
    fi
    ;;
  "Colloid-Dark")
    # Detectar variante según el tema GTK
    case "$THEME" in
      "Nordic")
        VARIANT="nord"
        ICON_THEME="Colloid-Nord-Dark"
        ;;
      "Dracula")
        VARIANT="dracula"
        ICON_THEME="Colloid-Dracula-Dark"
        ;;
      *)
        VARIANT=""
        ICON_THEME="Colloid-Dark"
        ;;
    esac

    if [[ ! -d "$HOME/.local/share/icons/$ICON_THEME" ]]; then
      git clone https://github.com/vinceliuice/Colloid-icon-theme.git "$TMP_DIR/Colloid"
      cd "$TMP_DIR/Colloid"
      INSTALL_CMD="./install.sh -d \"$HOME/.local/share/icons\""
      [[ -n "$VARIANT" ]] && INSTALL_CMD+=" -s $VARIANT"
      eval "$INSTALL_CMD"
      echo "🧩 Iconos Colloid instalados en modo usuario con variante: ${VARIANT:-default}"
    else
      echo "🧩 Iconos Colloid ya están instalados"
    fi
    ;;
  *)
    echo "❌ Iconos no soportados: $ICON_THEME"
    exit 1
    ;;
esac

# Aplicar configuración GTK
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Ejecutar script adicional si existe
[[ -f "$SCRIPT_DIR/apply_gtk_settings.sh" ]] && bash "$SCRIPT_DIR/apply_gtk_settings.sh"

echo "✅ Tema GTK oscuro aplicado correctamente: $THEME con iconos $ICON_THEME"
