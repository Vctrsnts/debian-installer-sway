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
    curl swaybg swaylock swayidle avahi-daemon acpi acpid
    pavucontrol pipewire playerctl polkit-kde-agent-1 pamixer
  )

  apt_install "${pkgs[@]}"
  
  sudo systemctl enable avahi-daemon
  sudo systemctl enable acpid

  log_success "🎉 Sway instalado."
}




