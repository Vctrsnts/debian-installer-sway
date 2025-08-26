#!/usr/bin/env bash

mod_nwg_look() {
  
  if [[ "${ENABLE_NWG_LOOK^^}" != "YES" ]]; then
      log_warn "🚫 NWG_LOOK desactivado en configuración."
      return
  fi
  
#  apt_install golang libgtk-3-dev libcairo2-dev libglib2.0-bin zip cmake cmake-extras unzip make

#  mkdir -p ~/Downloads 

#  cd ~/Downloads

#  wget https://github.com/nwg-piotr/nwg-look/archive/refs/tags/v0.2.6.zip
#  unzip v0.2.6.zip
#  cd nwg-look-0.2.6

#  make build
#  sudo make install

#  cd ..
#  rm -rf nwg-look-0.2.6

#  rm v0.2.6.zip
  set -e

  # === CONFIGURACIÓN ===
  VERSION="v0.2.7"
  URL="https://github.com/nwg-piotr/nwg-look/archive/refs/tags/${VERSION}.zip"

  # === 1. Actualizar repositorios ===
  sudo apt update

  # === 2. Instalar dependencias de compilación ===
  BUILD_DEPS=(
      build-essential
      pkg-config
      git
      make
      golang
      libgtk-3-dev
      libcairo2-dev
      libglib2.0-dev
      libpango1.0-dev
      libgdk-pixbuf2.0-dev
      libatk1.0-dev
      unzip
  )
  sudo apt install -y "${BUILD_DEPS[@]}"

  # === 3. Crear swap temporal de 2 GB ===
  echo "📦 Creando swap temporal de 2 GB..."
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile

  # === 4. Descargar última versión estable ===
  echo "⬇️ Descargando nwg-look ${VERSION}..."
  wget -O nwg-look.zip "$URL"

  # === 5. Descomprimir ===
  unzip -o nwg-look.zip
  cd "nwg-look-${VERSION#v}"

  # === 6. Compilar ===
  echo "⚙️ Compilando..."
  make build

  # === 7. Instalar con make install (iconos, .desktop, etc.) ===
  echo "📂 Instalando con make install..."
  sudo make install

  # === 8. Limpiar archivos temporales ===
  cd ..
  rm -rf "nwg-look-${VERSION#v}" nwg-look.zip

  # === 9. Desactivar y borrar swap temporal ===
  echo "🧹 Eliminando swap temporal..."
  sudo swapoff /swapfile
  sudo rm /swapfile

  # === 10. Eliminar dependencias de compilación ===
  echo "🗑️ Eliminando dependencias de compilación..."
  sudo apt purge -y "${BUILD_DEPS[@]}"
  sudo apt autoremove --purge -y
  sudo apt clean

  echo "✅ Instalación completada. 'nwg-look' está instalado e integrado en el escritorio."

}


