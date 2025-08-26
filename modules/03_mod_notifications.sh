#!/bin/bash
# Módulo: Notificaciones - Instalación de swaync (sin configuración)

mod_notifications(){
    if [[ "${ENABLE_NOTIFICATIONS^^}" != "YES" ]]; then
        log_warn "🚫 Notificaciones desactivadas en configuración."
        return
    fi

    log_info "Instalando Sway Notification Center (swaync)..."
    apt_install sway-notification-center

    log_success "🎉 Sway Notification Center instalado."
}
