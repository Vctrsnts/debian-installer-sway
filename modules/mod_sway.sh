#!/bin/bash
# Módulo: Sway - Instalación y configuración mínima

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

  # Crear directorio de configuración
  ensure_dirs_user "$USER_HOME/.config/sway"

  # Crear archivo principal con include
  local SWAY_CFG="$USER_HOME/.config/sway/config"
  if [[ -f "$SWAY_CFG" ]]; then
    cp "$SWAY_CFG" "$SWAY_CFG.bak"
    log_info "🗂 Backup creado: $SWAY_CFG.bak"
  fi

  write_as_user "$SWAY_CFG" <<'EOF'
# using directory
include $HOME/.config/sway/config.d/*
EOF

  log_success "🎉 Sway instalado y archivo de configuración creado."
}
