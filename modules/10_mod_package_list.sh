#!/bin/bash
# Módulo: Instalación desde lista de paquetes

mod_package_list(){
  [[ "${ENABLE_PACKAGE_LIST^^}" == "NO" ]] && { log_warn "Saltando instalación desde lista."; return; }
  [[ "${ENABLE_PACKAGE_LIST^^}" == "ASK" ]] && \
    ! ask_yes_no "¿Instalar todos los paquetes de package-list.txt?" "Y" && \
    { log_warn "Instalación desde lista omitida."; return; }

  local LIST_FILE="$ROOT_DIR/package-list.txt"
  [[ ! -f "$LIST_FILE" ]] && { log_warn "No existe $LIST_FILE."; return; }

  mapfile -t PKGS < <(grep -Ev '^\s*#|^\s*$' "$LIST_FILE")
  [[ ${#PKGS[@]} -eq 0 ]] && { log_warn "La lista está vacía."; return; }

  apt_install "${PKGS[@]}"
  log_success "Todos los paquetes de la lista instalados."
}
