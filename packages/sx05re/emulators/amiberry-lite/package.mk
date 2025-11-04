# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry-lite"
PKG_VERSION="e535218c72071b9579debad0d30ae99390d681c3"
PKG_ARCH="aarch64 arm"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/BlitterStudio/amiberry-lite"
PKG_URL="https://github.com/BlitterStudio/amiberry-lite.git"
PKG_DEPENDS_TARGET="toolchain linux libpcap glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123-compat libpng libmpeg2 libportmidi libserialport libenet"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"
PKG_EE_UPDATE=no

PKG_BUILD_FLAGS="-O3 -fno-strict-aliasing -fomit-frame-pointer -ffast-math"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DUSE_OPENGL=OFF -DCMAKE_BUILD_TYPE=Release -DUSE_UAENET_PCAP=OFF"
}

makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/amiberry-lite
  # mkdir -p ${INSTALL}/usr/config/amiberry-lite/controller

  # Copy ressources
  cp -a ${PKG_DIR}/config/*           ${INSTALL}/usr/config/amiberry-lite/
  cp -a data                          ${INSTALL}/usr/config/amiberry-lite/
  cp -a roms                          ${INSTALL}/usr/config/amiberry-lite/
  mkdir -p savestates                 ${INSTALL}/usr/config/amiberry-lite/
  mkdir -p screenshots                ${INSTALL}/usr/config/amiberry-lite/
  cp -a whdboot                       ${INSTALL}/usr/config/amiberry-lite/
  ln -s /storage/roms/bios 			  ${INSTALL}/usr/config/amiberry-lite/kickstarts
  mkdir -p							  ${INSTALL}/usr/config/amiberry-lite/plugins
  cp ${PKG_BUILD}/.${TARGET_NAME}/external/floppybridge/libfloppybridge.so ${INSTALL}/usr/config/amiberry-lite/plugins/
  cp ${PKG_BUILD}/.${TARGET_NAME}/external/capsimage/*.so ${INSTALL}/usr/config/amiberry-lite/plugins/

  # Create links to Retroarch controller files
  # ln -s /usr/share/retroarch/autoconfig/udev/8Bitdo_Pro_SF30_BT_B.cfg "${INSTALL}/usr/config/amiberry-lite/controller/8Bitdo SF30 Pro.cfg"
  ln -s "/tmp/joypads" "${INSTALL}/usr/config/amiberry-lite/controller"

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry-lite
    
  UAE="${INSTALL}/usr/config/amiberry-lite/conf/*.uae"
  for i in ${UAE}; do echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> ${i}; done

}
