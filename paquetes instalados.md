#!/bin/bash

# =========================
# Paquetes base para Sway
# =========================
pkgs=(
  sway                    # Gestor de ventanas tipo tiling para Wayland
  swaybg                  # Fondo de pantalla para Sway
  waybar                  # Barra de estado personalizable
  swaylock                # Bloqueo de pantalla
  swayidle                # Gestión de inactividad (bloqueo/apagado de pantalla)
  mako-notifier           # Servidor de notificaciones para Wayland
  wayland-protocols       # Protocolos necesarios para Wayland
  xwayland                # Compatibilidad con aplicaciones X11 en Wayland

  wofi                    # Lanzador de aplicaciones para Wayland
  polkitd                 # Demonio de PolicyKit (gestión de permisos)
  lxpolkit                # Interfaz gráfica para PolicyKit
  git                     # Control de versiones y descarga de repositorios

  lxsession               # Gestor de sesión ligero (opcional pero útil)
  lxappearance            # Configuración de temas GTK

  pcmanfm                 # Gestor de archivos ligero
  gvfs                    # Soporte de montaje y acceso a sistemas de archivos
  gvfs-backends           # Backends para gvfs (USB, red, etc.)
  udisks2                 # Demonio para gestión de discos y montaje automático

  clipman                 # Gestor de historial del portapapeles
  wl-clipboard            # Herramientas para copiar/pegar en Wayland

  pulseaudio              # Servidor de sonido
  pulseaudio-utils        # Utilidades para PulseAudio
  pamixer                 # Control de volumen desde terminal
  pavucontrol             # Control de volumen con interfaz gráfica

  xdg-user-dirs           # Directorios estándar de usuario (Documentos, Imágenes, etc.)
  xdg-utils               # Utilidades para integración de escritorio

  curl                    # Descarga de archivos desde terminal
  gpg                     # Cifrado y verificación de firmas
  unzip                   # Descompresión de archivos ZIP

  libpam0g                # Autenticación PAM
  libseat1                 # Gestión de asientos para Wayland (login sin root)
  fastfetch               # Información del sistema en terminal
  acpi                    # Información de batería y energía
  acpid                   # Demonio para eventos ACPI (tapa, batería, etc.)
  eza                     # Sustituto moderno de 'ls'
  greetd                  # Gestor de inicio de sesión
  wlgreet                 # Interfaz gráfica para greetd
  gsettings-desktop-schemas # Esquemas de configuración para aplicaciones GTK
)

# =========================
# Paquetes de usabilidad y estética
# =========================
extras=(
  btm                     # Monitor de recursos en terminal
  foot                    # Emulador de terminal para Wayland

  breeze-cursor-theme     # Tema de cursor Breeze
  bibata-cursor-theme     # Tema de cursor Bibata

  fonts-hack              # Fuente monoespaciada Hack
  fonts-inconsolata       # Fuente monoespaciada Inconsolata
  fonts-jetbrains-mono    # Fuente monoespaciada JetBrains Mono
  fonts-cascadia-code     # Fuente monoespaciada Cascadia Code
  fonts-fira-code         # Fuente monoespaciada Fira Code
  fonts-font-awesome      # Iconos Font Awesome
  fonts-mononoki          # Fuente monoespaciada Mononoki
  fonts-roboto            # Fuente Roboto
  fonts-ubuntu            # Fuente Ubuntu

  libglib2.0-bin          # Herramientas para trabajar con GLib
)

# =========================
# Instalación
# =========================
sudo apt update
sudo apt install -y "${pkgs[@]}" "${extras[@]}"
