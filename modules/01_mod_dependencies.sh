#!/bin/bash
# Módulo: Dependencies

mod_dep(){
  
  [[ "${ENABLE_DEPENDENCIES^^}" == "NO" ]] && { log_warn "🚫 Desactivada la instalacio de dependencies."; return; }

  # === 2. Instalar dependencias de compilación ===
  #local pkgs=(
  #  wget curl gpg
  #)

  #apt_install "${pkgs[@]}"

  log_info "🎉 Ha finalitzat la instalacio de les dependencies."
}
