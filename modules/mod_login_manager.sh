#!/bin/bash
# Módulo: Gestor de sesiones - SDDM, GDM3 o wlgreet (greetd)

mod_login_manager(){
  [[ "${ENABLE_LOGIN_MANAGER^^}" == "NO" ]] && { log_warn "Saltando gestor de sesiones."; return; }
  [[ "${ENABLE_LOGIN_MANAGER^^}" == "ASK" ]] && ! ask_yes_no "¿Instalar gestor de sesiones (SDDM, GDM3 o wlgreet)?" "Y" && { log_warn "Gestor de sesiones omitido."; return; }

  local manager="${LOGIN_MANAGER:-wlgreet}"  # Puedes definir LOGIN_MANAGER en modules.conf

  case "$manager" in
    "sddm")
      log_info "Instalando SDDM..."
      apt_install sddm
      sudo systemctl enable sddm
      log_success "SDDM instalado y habilitado."
      ;;

    "gdm3")
      log_info "Instalando GDM3..."
      apt_install gdm3
      sudo systemctl enable gdm3
      log_success "GDM3 instalado y habilitado."
      ;;

    "wlgreet")
      log_info "Instalando greetd con wlgreet (recomendado para Sway)..."
      apt_install greetd wlgreet sway

      # Crear configuración recomendada
      sudo mkdir -p /etc/greetd
      sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "sway --config /etc/greetd/sway-config"
user = "greeter"
EOF

      # Crear sway-config con fondo personalizado
      sudo tee /etc/greetd/sway-config >/dev/null <<EOF
exec swaybg -i /home/user/.config/background/login.jpg -m fill
exec wlgreet
EOF
      # Crear usuario 'greeter' si no existe
      if ! id "greeter" &>/dev/null; then
        sudo useradd -m -s /bin/bash greeter
        log_info "Usuario 'greeter' creado para greetd."
      fi

      # Permisos y grupos
      sudo usermod -aG video greeter
      sudo chown -R greeter:greeter /etc/greetd

      # Habilitar greetd
      sudo systemctl enable greetd

      log_success "wlgreet instalado y configurado con Sway como compositor."
      ;;

    *)
      log_error "Gestor de sesiones no reconocido: $manager"
      return 1
      ;;
  esac
}
