#!/bin/bash
set -euo pipefail

# Funciones
apt_install(){
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends "$@"
}

# cd $HOME/debian-installer-sway/custom-configs/greetd
# sudo cp * /etc/greetd/
# sudo chmod go+r /etc/greetd

  # GENERACIO DEL FITXERR SWAY-CONFIG PER AL FUNCIONAMENT DE GTKGREET + GREETD
  sudo cat << EOF > "/etc/greetd/sway-config"
exec "gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"

bindsym Mod4+Shift+e exec swaynag \
  -t warning \
  -m 'Que vols fer?' \
  -b 'Poweroff' 'systemctl poweroff' \
  -b 'Reboot' 'systemctl reboot'
EOF

# instalacion de aplicaciones externas
pkgs=(
  btm
)

apt_install "${pkgs[@]}"
