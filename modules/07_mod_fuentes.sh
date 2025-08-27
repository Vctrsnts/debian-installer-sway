#!/bin/bash
# Módulo: Fuentes - Instalación de Nerd Fonts + Inter + Noto Sans

mod_fuentes(){
  [[ "${ENABLE_FUENTES^^}" == "NO" ]] && { log_warn "Saltando fuentes."; return; }
  [[ "${ENABLE_FUENTES^^}" == "ASK" ]] && ! ask_yes_no "¿Instalar fuentes Nerd Fonts?" "Y" && { log_warn "Fuentes omitidas."; return; }

  log_info "Instalación de fuentes adicionales (Inter, Noto Sans)…"
  apt_install fonts-recommended fonts-font-awesome fonts-terminus
  
  log_info "Instalación de Nerd Fonts…"
  local FONT_DIR="$USER_HOME/.local/share/fonts"
  ensure_dirs_user "$FONT_DIR"

  # Selección de familias Nerd Fonts
  local fonts=(
    CascadiaCode
    FiraCode
    Hack
    Inconsolata
    JetBrainsMono
    Meslo
    Mononoki
    RobotoMono
    SourceCodePro
    UbuntuMono
  )

  for font in "${fonts[@]}"; do
    if [[ -d "$FONT_DIR/$font" ]] && find "$FONT_DIR/$font" -type f -name '*.ttf' | grep -q .; then
      log_info "Fuente '$font' ya instalada; omitiendo."
      continue
    fi
    log_info "Descargando e instalando: $font"
    local URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/${font}.zip"
    local ZIP_PATH="/tmp/${font}.zip"

    # Descarga
    if ! wget -q --show-progress "$URL" -O "$ZIP_PATH"; then
      log_warn "Fallo al descargar $font desde $URL; se omite."
      continue
    fi

    # Carpeta destino por fuente
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$FONT_DIR/$font"

    # Descomprimir y limpiar
    if unzip -qqo "$ZIP_PATH" -d "$FONT_DIR/$font"; then
      chown -R "$TARGET_USER:$TARGET_USER" "$FONT_DIR/$font"
      find "$FONT_DIR/$font" -type f ! -iname '*.ttf' ! -iname '*.otf' -delete || true
      log_success "Fuente $font instalada."
    else
      log_warn "No se pudo descomprimir $font; se omite."
    fi
    rm -f "$ZIP_PATH"
  done

  # Refrescar caché de fuentes
  sudo -u "$TARGET_USER" fc-cache -fv "$FONT_DIR" >/dev/null || fc-cache -fv "$FONT_DIR" >/dev/null || true
  log_success "Fuentes instaladas y caché refrescada."
}
