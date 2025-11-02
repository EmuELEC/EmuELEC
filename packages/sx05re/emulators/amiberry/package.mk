# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry"
PKG_VERSION="452783ae8c94a67984b664e9b24f0b99ad163dcd"
PKG_ARCH="aarch64 arm"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/BlitterStudio/amiberry"
PKG_URL="https://github.com/BlitterStudio/amiberry.git"
PKG_DEPENDS_TARGET="toolchain linux libpcap libenet glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123-compat libpng libmpeg2 libportmidi libserialport"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"
PKG_EE_UPDATE=no

PKG_BUILD_FLAGS="-O3 -fno-strict-aliasing -fomit-frame-pointer -ffast-math"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DUSE_OPENGL=OFF -DCMAKE_BUILD_TYPE=Release -DUSE_UAENET_PCAP=ON"
}

makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/amiberry
  # mkdir -p ${INSTALL}/usr/config/amiberry/controller

  # Copy ressources
  cp -a ${PKG_DIR}/config/*           ${INSTALL}/usr/config/amiberry/
  cp -a data                          ${INSTALL}/usr/config/amiberry/
  cp -a roms                          ${INSTALL}/usr/config/amiberry/
  mkdir -p savestates                 ${INSTALL}/usr/config/amiberry/
  mkdir -p screenshots                ${INSTALL}/usr/config/amiberry/
  cp -a whdboot                       ${INSTALL}/usr/config/amiberry/
  ln -s /storage/roms/bios 			  ${INSTALL}/usr/config/amiberry/kickstarts
  mkdir -p							  ${INSTALL}/usr/config/amiberry/plugins
  cp ${PKG_BUILD}/.${TARGET_NAME}/external/floppybridge/libfloppybridge.so ${INSTALL}/usr/config/amiberry/plugins/
  cp ${PKG_BUILD}/.${TARGET_NAME}/external/capsimage/*.so ${INSTALL}/usr/config/amiberry/plugins/

  # Create links to Retroarch controller files
  # ln -s /usr/share/retroarch/autoconfig/udev/8Bitdo_Pro_SF30_BT_B.cfg "${INSTALL}/usr/config/amiberry/controller/8Bitdo SF30 Pro.cfg"
  ln -s "/tmp/joypads" "${INSTALL}/usr/config/amiberry/controller"

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry
  cp -a ${PKG_DIR}/scripts/*          ${INSTALL}/usr/bin
  
  
  UAE="${INSTALL}/usr/config/amiberry/conf/*.uae"
  for i in ${UAE}; do echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> ${i}; done

}
