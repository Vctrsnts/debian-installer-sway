#!/bin/bash

while true; do
  IMAGE=$(find "$HOME/.config/background" -type f | shuf -n 1)
  pkill swaybg
  swaybg -i "$IMAGE" -m fill &
  sleep 3600
done
