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
THEME="Nordic"
ICON_THEME="Colloid-Darkk"

echo "🖤 Aplicando tema GTK oscuro: $THEME con iconos $ICON_THEME"

# Crear directorio temporal
TMP_DIR=$(mktemp -d)

# Instalar dependencias necesarias
sudo apt update
sudo apt install -y gtk2-engines-murrine git

# Instalar tema GTK
case "$THEME" in
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

#!/bin/bash

# Directorio temporal
TMP_DIR="/tmp/icon-themes"
mkdir -p "$TMP_DIR"

# Instalar Papirus-Dark (modo sistema)
if [[ ! -d "/usr/share/icons/Papirus-Dark" ]]; then
  sudo apt update
  sudo apt install -y papirus-icon-theme
  echo "🧩 Iconos Papirus-Dark instalados (modo sistema)"
else
  echo "🧩 Iconos Papirus-Dark ya están instalados"
fi

# Instalar Tela-Dark (modo usuario)
if [[ ! -d "$HOME/.local/share/icons/Tela-Dark" ]]; then
  git clone https://github.com/vinceliuice/Tela-icon-theme.git "$TMP_DIR/Tela"
  cd "$TMP_DIR/Tela" && ./install.sh -d "$HOME/.local/share/icons" -c dark
  echo "🧩 Iconos Tela-Dark instalados en modo usuario"
else
  echo "🧩 Iconos Tela-Dark ya están instalados"
fi

# Instalar Colloid con variantes
COLLOID_REPO="https://github.com/vinceliuice/Colloid-icon-theme.git"
COLLOID_DIR="$TMP_DIR/Colloid"
VARIANT_LIST=("default" "nord" "dracula" "gruvbox" "tokyo-night")

if [[ ! -d "$COLLOID_DIR" ]]; then
  git clone "$COLLOID_REPO" "$COLLOID_DIR"
fi

cd "$COLLOID_DIR"

for VARIANT in "${VARIANT_LIST[@]}"; do
  THEME_NAME="Colloid-${VARIANT^}-Dark"
  ICON_PATH="$HOME/.local/share/icons/$THEME_NAME"

  if [[ ! -d "$ICON_PATH" ]]; then
    if [[ "$VARIANT" == "default" ]]; then
      ./install.sh -d "$HOME/.local/share/icons"
    else
      ./install.sh -d "$HOME/.local/share/icons" -s "$VARIANT"
    fi
    echo "🧩 Iconos Colloid instalados con variante: $VARIANT"
  else
    echo "🧩 Iconos Colloid ya están instalados: $VARIANT"
  fi
done

echo "✅ Instalación de iconos completada"

# Aplicar configuración GTK
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Nord-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Sans 10'

# Ejecutar script adicional si existe
[[ -f "$SCRIPT_DIR/apply_gtk_settings.sh" ]] && bash "$SCRIPT_DIR/apply_gtk_settings.sh"

echo "✅ Tema GTK oscuro aplicado correctamente: $THEME con iconos $ICON_THEME"
