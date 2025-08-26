#!/bin/bash
# Módulo: Waybar - Instalación mínima (sin configuración)

mod_waybar(){
  [[ "${ENABLE_WAYBAR^^}" == "NO" ]] && { log_warn "🚫 Saltando Waybar."; return; }
  
  apt_install waybar wlogout xdg-user-dirs xdg-utils

  log_success "🎉 Waybar instalado."
}
