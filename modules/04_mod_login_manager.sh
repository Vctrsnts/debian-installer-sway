#!/bin/bash
# Módulo: Login Manager - Instalación de gestor de inicio (sin configuración)

mod_login_manager(){
    if [[ "${ENABLE_LOGIN_MANAGER^^}" != "YES" ]]; then
        log_warn "🚫 Login Manager desactivado en configuración."
        return
    fi

    case "${LOGIN_MANAGER,,}" in
        gdm3)
            log_info "Instalando GDM3..."
            apt_install gdm3
            ;;
        sddm)
            log_info "Instalando SDDM..."
            apt_install sddm
            ;;
        wlgreet)
            log_info "Instalando greetd + wlgreet..."
            apt_install greetd wlgreet
            ;;
        lightdm)
            log_info "Instalando LightDM..."
            apt_install lightdm
            ;;
        *)
            log_warn "Gestor de inicio desconocido: ${LOGIN_MANAGER}. Opciones válidas: gdm3, sddm, wlgreet, lightdm."
            return
            ;;
    esac

    log_success "🎉 Gestor de inicio '${LOGIN_MANAGER}' instalado."
}
