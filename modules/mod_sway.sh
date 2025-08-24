#!/bin/bash
# Módulo: Sway - Instalación y configuración mínima

mod_sway(){
  [[ "${ENABLE_SWAY^^}" == "NO" ]] && { log_warn "Saltando Sway."; return; }
  [[ "${ENABLE_SWAY^^}" == "ASK" ]] && ! ask_yes_no "¿Instalar Sway y base?" "Y" && { log_warn "Sway omitido."; return; }

  local pkgs=(
    sway xwayland xdg-desktop-portal-wlr
    grim slurp wl-clipboard cliphist
    fonts-dejavu-core fonts-noto-color-emoji
    jq curl swaybg swaylock swayidle
  )
  apt_install "${pkgs[@]}"

  ensure_dirs_user "$USER_HOME/.config/sway"
  local SWAY_CFG="$USER_HOME/.config/sway/config"
  if [[ ! -f "$SWAY_CFG" ]]; then
    write_as_user "$SWAY_CFG" <<'EOF'
# Configuración mínima de Sway
set $mod Mod4
set $term foot
set $menu wofi --show drun

font pango:DejaVu Sans 10

floating_modifier $mod
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+e exec "swaymsg exit"
bindsym $mod+Shift+c reload

output * bg #1e1e2e solid_color
seat seat0 xcursor_theme 'Adwaita' 24

# Clipboard history (cliphist) atajos
bindsym $mod+Shift+v exec bash -lc 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'

include ~/.config/sway/conf.d/*
EOF
  fi
  ensure_dirs_user "$USER_HOME/.config/sway/conf.d"
  log_success "Sway instalado y configurado mínimamente."
}
