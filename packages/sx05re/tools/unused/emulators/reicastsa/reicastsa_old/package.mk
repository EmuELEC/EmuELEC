# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="reicastsa_old"
PKG_VERSION="69371070f2c04a832f45e238afd703596f6e19f7"
PKG_SHA256="ae1f64a520a1d14281b5745b43105e0d5dc6b37e43c3f594a10a0ece7edc1709"
PKG_EE_UPDATE="no"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/reicast/reicast-emulator"
PKG_URL="https://github.com/reicast/reicast-emulator/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_DIR="reicast-emulator-${PKG_VERSION}*"
PKG_DEPENDS_TARGET="toolchain alsa libpng libevdev python-evdev"
PKG_SHORTDESC="Reicast is a multi-platform Sega Dreamcast emulator"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

PKG_PATCH_DIRS="${PROJECT}"

make_target() {
  cd ${PKG_BUILD}/shell/linux
  make CC=${CC} CXX=${CXX} AS=${CC} STRIP=${STRIP} EXTRAFLAGS="-I${PKG_BUILD}/shell/linux-deps/include" platform=odroidc2 reicast.elf
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp reicast.elf ${INSTALL}/usr/bin/reicast_old
  
  mkdir -p ${INSTALL}/usr/config
  cp -r ${PKG_DIR}/config/* ${INSTALL}/usr/config/
 
}
