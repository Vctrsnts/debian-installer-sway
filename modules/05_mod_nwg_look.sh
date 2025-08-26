#!/usr/bin/env bash

mod_nwg_look() {
  
  if [[ "${ENABLE_NWG_LOOK^^}" != "YES" ]]; then
      log_warn "🚫 NWG_LOOK desactivado en configuración."
      return
  fi
  
  apt_install golang libgtk-3-dev libcairo2-dev libglib2.0-bin zip cmake cmake-extras unzip

  mkdir -p ~/Downloads 

  cd ~/Downloads

  wget https://github.com/nwg-piotr/nwg-look/archive/refs/tags/v0.2.6.zip
  unzip v0.2.6.zip
  cd nwg-look-0.2.6

  make build
  sudo make install

  cd ..
  rm -rf nwg-look-0.2.6

  rm v0.2.6.zip
}


