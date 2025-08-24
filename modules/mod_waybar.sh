#!/bin/bash
# Módulo: Waybar - Instalación y configuración básica

mod_waybar(){
  [[ "${ENABLE_WAYBAR^^}" == "NO" ]] && { warn "Saltando Waybar."; return; }
  apt_install waybar

  ensure_dirs_user "$USER_HOME/.config/waybar"

  write_as_user "$USER_HOME/.config/waybar/config" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["sway/workspaces", "sway/mode"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"],
  "clock": { "format": "{:%a %d %b  %H:%M}" },
  "battery": { "format": "{capacity}% {icon}", "format-icons": ["","","","",""] }
}
EOF

  write_as_user "$USER_HOME/.config/waybar/style.css" <<'EOF'
* { font-family: "DejaVu Sans", "Noto Color Emoji"; font-size: 12px; }
window { background: rgba(30,30,46,0.6); }
#workspaces button.focused { color: #89b4fa; }
#clock { padding: 0 10px; }
EOF

  log_success "Waybar instalado."
}
