#!/bin/bash

chosen=$(echo -e " Apagar\n Reiniciar\n Cerrar sesión" | \
  wofi --dmenu --prompt "¿Que quieres hacer?" --width 300 --height 200)

case "$chosen" in
  " Apagar") systemctl poweroff ;;
  " Reiniciar") systemctl reboot ;;
  " Cerrar sesión") swaymsg exit ;;
  *) exit 1 ;;
esac
