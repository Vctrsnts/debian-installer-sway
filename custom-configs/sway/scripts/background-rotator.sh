#!/bin/bash

while true; do
  IMAGE=$(find "$HOME/.config/backgrounds" -type f | shuf -n 1)
  pkill -x swaybg   # Mata solo procesos swaybg
  swaybg -i "$IMAGE" -m fill &
  sleep 3600 # 1 hora
done
