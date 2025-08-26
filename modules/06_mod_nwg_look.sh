#!/usr/bin/env bash

mod_nwg_look() {
  
  [[ "${ENABLE_NWG_LOOK^^}" == "NO" ]] && { log_warn "🚫 NWG_LOOK desactivado en configuración."; return; }
  
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
      libgdk-pixbuf-xlib-2.0-dev
      libatk1.0-dev
      unzip
  )
  sudo apt install -y "${BUILD_DEPS[@]}"

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
  
  # === 9. Borramos directorio go ===
  sudo rm -rf ~/go

  # === 10. Eliminar dependencias de compilación ===
  echo "🗑️ Eliminando dependencias de compilación..."
  sudo apt purge -y "${BUILD_DEPS[@]}"
  sudo apt autoremove --purge -y
  sudo apt clean

  echo "✅ Instalación completada. 'nwg-look' está instalado e integrado en el escritorio."

}


