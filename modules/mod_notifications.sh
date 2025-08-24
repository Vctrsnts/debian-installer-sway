#!/bin/bash
# Módulo: Notificaciones - Instalación y configuración de swaync (Sway Notification Center)

mod_notifications(){
    if [[ "${ENABLE_NOTIFICATIONS^^}" != "YES" ]]; then
        log_warn "Notificaciones desactivadas en configuración."
        return
    fi

    log_info "Instalando Sway Notification Center (swaync)..."
    apt_install sway-notification-center

    # Crear carpeta de configuración si no existe
    local SWAYNC_DIR="$USER_HOME/.config/swaync"
    ensure_dirs_user "$SWAYNC_DIR"

    # Copiar configuración por defecto del sistema si no existe
    if [[ ! -f "$SWAYNC_DIR/config.json" ]]; then
        if [[ -f /etc/xdg/swaync/config.json ]]; then
            sudo -u "$TARGET_USER" cp /etc/xdg/swaync/config.json "$SWAYNC_DIR/"
        else
            log_warn "No se encontró config.json por defecto, se creará uno mínimo."
            cat <<EOF | write_as_user "$SWAYNC_DIR/config.json"
{
    "positionX": "right",
    "positionY": "top",
    "control-center-margin-top": 40,
    "control-center-margin-bottom": 10,
    "control-center-margin-left": 10,
    "control-center-margin-right": 10
}
EOF
        fi
    fi

    # Copiar estilo CSS por defecto si no existe
    if [[ ! -f "$SWAYNC_DIR/style.css" ]]; then
        if [[ -f /etc/xdg/swaync/style.css ]]; then
            sudo -u "$TARGET_USER" cp /etc/xdg/swaync/style.css "$SWAYNC_DIR/"
        else
            log_warn "No se encontró style.css por defecto, se creará uno mínimo."
            echo "/* Estilo por defecto para swaync */" | write_as_user "$SWAYNC_DIR/style.css"
        fi
    fi

    # Añadir swaync al arranque de Sway
    local SWAY_CFG="$USER_HOME/.config/sway/config"
    [[ -f "$SWAY_CFG" ]] || { warn "No existe $SWAY_CFG; creando base."; mod_sway; }
    upsert_line "$SWAY_CFG" "exec swaync" "exec swaync"

    log_success "Sway Notification Center instalado y configurado."
}
