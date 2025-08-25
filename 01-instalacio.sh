#!/bin/bash
set -e

# =======================
# Rutas y configuración
# =======================
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_FILE="$ROOT_DIR/modules.conf"

# Cargar configuración externa
if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    log_warn "[WARN] No se encontró modules.conf. Usando valores por defecto (YES)"
    ENABLE_SWAY="YES"
    ENABLE_WAYBAR="YES"
    LAUNCHER_MODE="ROFI"
    ENABLE_WEZTERM="YES"
    ENABLE_NOTIFICATIONS="YES"
    ENABLE_THEMES="YES"
    ENABLE_LOGIN_MANAGER="YES"
    ENABLE_USER_EXTRAS="YES"
    ENABLE_FUENTES="YES"
    ENABLE_CONFIGS="YES"
    ENABLE_PACKAGE_LIST="YES"
fi

# =======================
# Funciones comunes
# =======================
# =======================
# Funciones de log con estilo
# =======================
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m' # Sin color

log_success() {
  echo -e "${GREEN}=== $1 ===${NC}"
}

log_info() {
  echo -e "${BLUE}--- $1 ---${NC}"
}

log_warn() {
  echo -e "${YELLOW}>>> $1 <<<${NC}"
}

log_error() {
  echo -e "${RED}!!! $1 !!!${NC}"
}

echo -e "${BLUE}"
echo "=========================================="
echo "     INICIANDO INSTALACIÓN DE SWAY        "
echo "=========================================="
echo -e "${NC}"

apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y "$@"
}

ensure_dirs_user(){
    local dir="$1"
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$dir"
}

write_as_user(){
    local file="$1"
    shift
    install -D -m 644 -o "$TARGET_USER" -g "$TARGET_USER" /dev/stdin "$file"
}

upsert_line(){
    local file="$1" pattern="$2" newline="$3"
    grep -qF "$pattern" "$file" \
        && sed -i "s|^.*$pattern.*$|$newline|" "$file" \
        || echo "$newline" >> "$file"
}

pkg_available(){
    dpkg -s "$1" &>/dev/null
}

# =======================
# Variables internas
# =======================
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME="$(eval echo "~$TARGET_USER")"

# =======================
# Verificar e instalar Git
# =======================
if ! command -v git &> /dev/null; then
    log_warn "Git no está instalado. Se procederá a instalarlo..."
    apt_install git
else
    log_info "Git ya está instalado."
fi

# =======================
# Cargar módulos
# =======================
for module in "$ROOT_DIR"/modules/*.sh; do
    source "$module"
done

# =======================
# Ejecución condicional
# =======================
[[ "$ENABLE_SWAY" == "YES" ]]            && mod_sway
[[ "$ENABLE_WAYBAR" == "YES" ]]          && mod_waybar
[[ "$LAUNCHER_MODE" == "ROFI" ]]         && mod_launcher
[[ "$ENABLE_WEZTERM" == "YES" ]]         && mod_terminal
[[ "$ENABLE_NOTIFICATIONS" == "YES" ]]   && mod_notifications
[[ "$ENABLE_THEMES" == "YES" ]]          && mod_themes
[[ "$ENABLE_LOGIN_MANAGER" == "YES" ]]   && mod_login_manager
[[ "$ENABLE_USER_EXTRAS" == "YES" ]]     && mod_user_extras
[[ "$ENABLE_PACKAGE_LIST" == "YES" ]]    && mod_package_list
[[ "$ENABLE_FUENTES" == "YES" ]]         && mod_fuentes
[[ "$ENABLE_CONFIGS" == "YES" ]]         && mod_configs
# =======================
# Instalacio de themes
# =======================
if [ "${THEME_DARK}" = "YES" ]; then
    log_info "Instalando tema oscuro"
    bash modules/theme-dark/install.sh
fi

log_success "Instalación y configuración completadas."
