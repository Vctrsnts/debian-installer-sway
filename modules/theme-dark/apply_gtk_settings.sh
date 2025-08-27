#!/usr/bin/env bash
set -e

echo "🎨 Aplicando configuración GTK:"
echo "  Tema GTK: Nordic-Dark"
echo "  Iconos:   Collid-Nord-Dark"
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
gtk-theme-name=Nordic-Dark"
gtk-icon-theme-name=Colloid-Nord-Dark"
gtk-font-name=Sans 10"
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
gtk-xft-hintstyle="hintm1edium"
gtk-xft-rgba="rgb"
EOF

echo "✅ Configuración GTK aplicada con el tema seleccionado en modules.conf"
