# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry"
PKG_VERSION="ecef2fd19f61e9360869eb9d5ebe1ad4c5019c14"
PKG_ARCH="aarch64 arm"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/midwan/amiberry"
PKG_URL="https://github.com/midwan/amiberry.git"
PKG_DEPENDS_TARGET="toolchain linux glibc bzip2 zlib SDL2 SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123-compat libpng libmpeg2"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"
PKG_EE_UPDATE=no

pre_configure_target() {
  cd ${PKG_BUILD}
  local DEVICE_PLATFORMS=('aarch64' 'arm')

  case "${DEVICE}" in
    'Amlogic-old')
      DEVICE_PLATFORMS=('a64' 'AMLGX')
      ;;
    'Amlogic-ng'|'Amlogic-ne'|'Amlogic-ogu')
      DEVICE_PLATFORMS=('n2' 'AMLG12B')
      ;;
    'OdroidGoAdvance'|'GameForce')
      DEVICE_PLATFORMS=('oga' 'RK3326')
      ;;
    'RK356x'|'OdroidM1')
      DEVICE_PLATFORMS=('a64' 'a64')
      ;;
    *)
      echo "Refuse to build ${PKG_NAME} for device ${DEVICE}!" >&2
      false
      ;;
  esac
  local AMIBERRY_PLATFORM
  case "${ARCH}" in 
    'aarch64')
      AMIBERRY_PLATFORM="${DEVICE_PLATFORMS[0]}"
      ;;
    'arm')
      AMIBERRY_PLATFORM="${DEVICE_PLATFORMS[1]}"
      ;;
    *)
      echo "Refuse to build ${PKG_NAME} for arch ${ARCH}!" >&2
      false
      ;;
  esac

  sed -i "s|AS     = as|AS     \?= as|" Makefile
  PKG_MAKE_OPTS_TARGET+=" all PLATFORM=${AMIBERRY_PLATFORM} SDL_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"
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
  cp -a savestates                    ${INSTALL}/usr/config/amiberry/
  cp -a screenshots                   ${INSTALL}/usr/config/amiberry/
  cp -a whdboot                       ${INSTALL}/usr/config/amiberry/
  ln -s /storage/roms/bios 			  ${INSTALL}/usr/config/amiberry/kickstarts

  # Create links to Retroarch controller files
  # ln -s /usr/share/retroarch/autoconfig/udev/8Bitdo_Pro_SF30_BT_B.cfg "${INSTALL}/usr/config/amiberry/controller/8Bitdo SF30 Pro.cfg"
  ln -s "/tmp/joypads" "${INSTALL}/usr/config/amiberry/controller"

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry
  cp -a ${PKG_DIR}/scripts/*          ${INSTALL}/usr/bin
  ln -sf /usr/lib/libcapsimage.so.5.1 ${INSTALL}/usr/config/amiberry/capsimg.so
  
  UAE="${INSTALL}/usr/config/amiberry/conf/*.uae"
  for i in ${UAE}; do echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> ${i}; done

}
