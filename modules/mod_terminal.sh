#!/bin/bash
# Módulo: Terminal - Instalación de WezTerm

mod_terminal(){
  [[ "${ENABLE_WEZTERM^^}" == "NO" ]] && { warn "Saltando WezTerm."; return; }
  [[ "${ENABLE_WEZTERM^^}" == "ASK" ]] && ! ask_yes_no "¿Instalar WezTerm como terminal?" "Y" && { warn "WezTerm omitido."; return; }
  
  local pkgs=(
    curl gpg
  )
  apt_install "${pkgs[@]}"

  log_info "Añadiendo el repositorio de WezTerm e instalando..."

  # Descargar la clave GPG
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

  # Agregar el repositorio
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

  # Instalar WezTerm
  apt_install wezterm

  # Crear directorio de configuración
  ensure_dirs_user "$USER_HOME/.config/wezterm"

  log_success "WezTerm ha sido instalado correctamente."
}
