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

# Usar las variables del conf, o valores por defecto si no están
GTK_THEME=${THEME_DARK_NAME:-"Materia-dark"}
ICON_THEME=${ICON_DARK_NAME:-"Papirus-Dark"}
FONT_NAME=${GTK_FONT_NAME:-"Sans 10"}
CURSOR_THEME=${GTK_CURSOR_THEME:-"Adwaita"}
CURSOR_SIZE=${GTK_CURSOR_SIZE:-0}

echo "🎨 Aplicando configuración GTK:"
echo "  Tema GTK: $GTK_THEME"
echo "  Iconos:   $ICON_THEME"
echo "  Fuente:   $FONT_NAME"
echo "  Cursor:   $CURSOR_THEME ($CURSOR_SIZE px)"

# GTK3
mkdir -p "$HOME/.config/gtk-3.0"
cat << EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Nordic
gtk-icon-theme-name=Colloid-Nord-Dark
gtk-font-name=$FONT_NAME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=$CURSOR_SIZE
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
gtk-theme-name=Nordic"
gtk-icon-theme-name=Colloid-Nord-Dark"
gtk-font-name=Sans 10"
gtk-cursor-theme-name="$CURSOR_THEME"
gtk-cursor-theme-size=$CURSOR_SIZE
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

echo "✅ Configuración GTK aplicada con el tema seleccionado en modules.conf"
