#!/bin/bash
# Módulo: Sway - Instalación mínima (sin configuración)

mod_sway() {
  [[ "${ENABLE_SWAY^^}" == "NO" ]] && { log_warn "🚫 Saltando Sway."; return; }
  [[ "${ENABLE_SWAY^^}" == "ASK" ]] && \
    ! ask_yes_no "¿Instalar Sway y base?" "Y" && \
    { log_warn "📁 Sway omitido."; return; }

  local pkgs=(
    sway xwayland
    wl-clipboard cliphist
    fonts-dejavu-core fonts-noto-color-emoji
    curl swaybg swaylock swayidle
  )

  apt_install "${pkgs[@]}"

  log_success "🎉 Sway instalado."
}
