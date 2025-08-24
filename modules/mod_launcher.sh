#!/bin/bash
# Módulo: Launcher - Instalación y configuración de lanzador (rofi/wofi/tofi/yofi)

choose_launcher_pkg(){
  case "${LAUNCHER_MODE^^}" in
    "ROFI")
      echo "rofi|rofi -show drun -show-icons"
      ;;
    "WOFI")
      echo "wofi|wofi --show drun"
      ;;
    "TOFI")
      echo "tofi|tofi --drun"
      ;;
    "YOFI")
      echo "yofi|yofi --show drun"
      ;;
    "AUTO"|"")
      # Orden de prioridad si está en AUTO
      if pkg_available rofi; then
        echo "rofi|rofi -show drun -show-icons"
      elif pkg_available wofi; then
        echo "wofi|wofi --show drun"
      elif pkg_available tofi; then
        echo "tofi|tofi --drun"
      elif pkg_available yofi; then
        echo "yofi|yofi --show drun"
      else
        return 1
      fi
      ;;
    *)
      log_warn "Launcher desconocido en LAUNCHER_MODE: $LAUNCHER_MODE"
      return 1
      ;;
  esac
}

mod_launcher(){
  if [[ "${LAUNCHER_MODE^^}" == "ASK" ]]; then
    ask_yes_no "¿Instalar lanzador (rofi/wofi/tofi/yofi)?" "Y" || { log_warn "Lanzador omitido."; return; }
  fi

  local choice
  if ! choice="$(choose_launcher_pkg)"; then
    log_warn "No se detectó paquete de lanzador disponible."
    return
  fi

  local pkg="${choice%%|*}"
  local cmd="${choice##*|}"

  apt_install "$pkg"

  local SWAY_CFG="$USER_HOME/.config/sway/config"
  [[ -f "$SWAY_CFG" ]] || { warn "No existe $SWAY_CFG; creando base."; mod_sway; }

  upsert_line "$SWAY_CFG" "set \$menu " "set \$menu $cmd"
  log_success "Lanzador '$pkg' instalado y configurado en Sway."
}
