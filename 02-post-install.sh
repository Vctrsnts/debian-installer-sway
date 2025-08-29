#!/bin/bash
set -euo pipefail

# Funciones
apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends "$@"
}
log_success() {
  echo -e "${GREEN}"
  echo "=========================================="
  echo -e "=== $1 ==="
  echo "=========================================="
  echo -e "${NC}"
}

log_success "Procedim a la instalacio de paquets suplementaris"
# instalacion de aplicaciones externas
pkgs=(
  btm
  thunar thunar-volman 
  gvfs gvfs-backends 
  breeze-cursor-theme
  greetd gtkgreet
  eza foot
)

apt_install "${pkgs[@]}"

# cd $HOME/debian-installer-sway/custom-configs/greetd
log_success "Procedim a realitzar la configuració de greetd i gtkgreet"
sudo cp $HOME/debian-installer-sway/custom-configs/greetd/* /etc/greetd/
sudo chmod go+r /etc/greetd
sudo systemctl enable greetd

log_success "Procedim a copia el wallpaper de gtkgreet"
sudo mv $HOME/.config/backgrounds/login.jpg /usr/share/backgrounds/login.jpg
sudo chmod 644 /usr/share/backgrounds/login.jpg
