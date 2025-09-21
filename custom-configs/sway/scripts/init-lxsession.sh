#!/bin/bash
# Script para iniciar lxsession con perfil sway

PERFIL="sway"

# Matar cualquier instancia previa de lxsession
pkill -x lxsession

# Esperar un momento
sleep 1

# Lanzar lxsession con el perfil sway
lxsession -s "$PERFIL" -e "$PERFIL" &
