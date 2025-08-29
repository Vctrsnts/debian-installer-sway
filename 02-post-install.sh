#!/bin/bash
set -euo pipefail

# Funciones
apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends "$@"
}

# cd $HOME/debian-installer-sway/custom-configs/greetd
sudo cp $HOME/debian-installer-sway/custom-configs/greetd/* /etc/greetd/
sudo chmod go+r /etc/greetd
sudo systemctl enable greetd

# instalacion de aplicaciones externas
pkgs=(
  btm
  thunar thunar-volman gvfs
)

apt_install "${pkgs[@]}"
