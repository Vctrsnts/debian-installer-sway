#!/bin/bash

# Este script instala los componentes esenciales para un entorno Sway funcional y minimalista
# en Debian Unstable, con todos los paquetes en una única sección de instalación.

# Función para manejar errores
function log_error() {
  echo -e "${RED}"
  echo "=========================================="
  echo -e "!!! Ha ocurrido un fallo en el script. Saliendo... !!!"
  echo "=========================================="
  echo -e "${NC}"
  exit 1
}
function log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}
function log_info() {
  echo -e "${BLUE}"
  echo "=========================================="
  echo -e "--- $1 ---"
  echo "=========================================="
  echo -e "${NC}"
}
function apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends "$@"
}
function ensure_dirs_user(){
    local dir="$1"
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$dir"
}
mod_terminal(){
  log_info "Añadiendo el repositorio de WezTerm e instalando..."

  # Descargar la clave GPG
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

  # Agregar el repositorio
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
    | sudo tee /etc/apt/sources.list.d/wezterm.list

  # Instalar WezTerm
  apt_install wezterm

  log_success "🎉 WezTerm ha sido instalado correctamente."
}
mod_fuentes(){
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

# Comprobar si el script se ejecuta como root
#if [[ $EUID -ne 0 ]]; then
#   echo "Este script debe ser ejecutado como root (o con sudo)."
#   exit 1
#fi

log_success "Iniciando la instalación de las aplicaciones esenciales para Sway en Debian Unstable..."

# Actualizar el índice de paquetes y el sistema
log_success "Actualizando el sistema..."

sudo apt update
sudo apt upgrade -y

# Instalar todos los paquetes necesarios en una sola línea
# Incluye los componentes de Sway, utilidades del sistema, audio, red, y herramientas de usuario
log_success "Instalando todos los paquetes necesarios..."

local pkgs=(
    sway swaybg waybar swaylock swayidle 
    sway-notification-center 
    wayland-protocols xwayland 
    rofi lxappearance pavucontrol 
    pipewire wireplumber alsa-utils 
    polkitd lxpolkit 
    network-manager-gnome 
    brightnessctl grim slurp 
    clipman wl-clipboard 
    avahi-daemon acpi acpid 
    btop greetd gtkgreet
    
)

sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

apt_install "${pkgs[@]}"

log_info "Configurando Greetd y Gtkgreet..."

# Crear el archivo de configuración de Greetd
cat << EOF | sudo tee /etc/greetd/config.toml > /dev/null
[terminal]
vt = 7

[default_session]
user = "greeter"
command = "gtkgreet"
EOF

log_info "Archivo /etc/greetd/config.toml creado."

# Crear el archivo de configuración de Gtkgreet
# NOTA: Debes reemplazar "/ruta/a/tu/imagen.jpg" con la ruta a tu fondo de pantalla.
cat << EOF | sudo tee /etc/greetd/gtkgreet.toml > /dev/null
[greeter]
background = "/ruta/a/tu/imagen.jpg"

[default_session]
command = "sway"
EOF

log_info "Archivo /etc/greetd/gtkgreet.toml creado."

# Habilitar el servicio de greetd
log_info "Habilitando el servicio de greetd..."

sudo systemctl enable greetd.service

mod_terminal

echo "Instalación completada. Se han instalado todos los paquetes necesarios."
echo ""
echo "Recuerda que para la configuración, necesitas:"
echo "1. Añadir los siguientes comandos a tu archivo de configuración de Sway (~/.config/sway/config):"
echo "   exec lxpolkit"
echo "   exec --no-startup-id clipman"
echo "   exec sway-notification-center"
echo "2. Configurar una combinación de teclas para rofi, por ejemplo: bindsym $mod+d exec rofi -show drun"
echo "3. Para establecer un fondo de pantalla, añade la siguiente línea a tu archivo de configuración de Sway, reemplazando la ruta con la de tu imagen:"
echo "   output * bg /ruta/a/tu/imagen.jpg fill"
echo ""
echo "Información sobre los temas:"
echo "Los temas de iconos 'Colloid Dark' y de apariencia 'Nordic' no se encuentran en los repositorios de Debian. Deberás descargarlos e instalarlos manualmente."
