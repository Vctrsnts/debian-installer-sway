#!/bin/bash

# Archivo de configuración GTK3
GTK3_CONF="$HOME/.config/gtk-3.0/settings.ini"

# Cursor actual
current=$(grep "gtk-cursor-theme-name" "$GTK3_CONF" | cut -d'=' -f2 | tr -d ' ')

# Alternar entre Breeze y Bibata
if [ "$current" = "breeze_cursors" ]; then
    new="Bibata-Modern-Classic"
else
    new="breeze_cursors"
fi

# Actualizar GTK3
sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$new/" "$GTK3_CONF"

# Actualizar GTK2
sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$new/" "$HOME/.gtkrc-2.0"

# Exportar variable de entorno para la sesión actual
export XCURSOR_THEME=$new

# Aplicar en sway (requiere reload)
swaymsg "seat seat0 xcursor_theme $new 24"

notify-send "Cursor cambiado" "Nuevo cursor: $new"
