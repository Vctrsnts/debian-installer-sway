#!/bin/bash
# Módulo: Configuraciones personalizadas (centralizado)

mod_configs() {
    [[ "${ENABLE_CONFIGS^^}" == "NO" ]] && { log_warn "🔕 Saltando copia de configuraciones."; return; }
    [[ "${ENABLE_CONFIGS^^}" == "ASK" ]] && \
        ! ask_yes_no "¿Quieres copiar los archivos de configuración personalizados?" "N" && \
        { log_warn "📁 Copia de configuraciones omitida."; return; }

    local SRC_DIR="$ROOT_DIR/custom-configs"
    [[ ! -d "$SRC_DIR" ]] && { log_warn "🚫 No existe $SRC_DIR, se omite."; return; }

    log_info "📦 Copiando configuraciones personalizadas desde $SRC_DIR..."

    while IFS= read -r -d '' item; do
        rel_path="${item#$SRC_DIR/}"

        case "$rel_path" in
            bashrc|zshrc|.bashrc|.zshrc)
                dest_path="$USER_HOME/.${rel_path#.}"   # asegura el punto delante
                dest_dir="$USER_HOME"
                ;;
            background/*)
                dest_path="$USER_HOME/.config/$rel_path"
                dest_dir="$USER_HOME/.config/background"
                ;;
            *)
                dest_path="$USER_HOME/.config/$rel_path"
                dest_dir="$USER_HOME/.config/$(dirname "$rel_path")"
                ;;
        esac

        ensure_dirs_user "$dest_dir"

        # Backup si existe y es distinto
        if [[ -f "$dest_path" ]] && ! cmp -s "$item" "$dest_path"; then
            cp "$dest_path" "$dest_path.bak"
            log_info "🗂 Backup creado: ${dest_path}.bak"
        fi

        install -D -m 644 -o "$TARGET_USER" -g "$TARGET_USER" "$item" "$dest_path"
        log_success "✅ Instalado: $rel_path → $dest_path"
    done < <(find "$SRC_DIR" -type f -print0)

    log_success "🎉 Todas las configuraciones personalizadas aplicadas."
}
