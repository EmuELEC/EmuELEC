# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="reicastsa"
if [[ "${DEVICE}" == "Amlogic-ng" || "${DEVICE}" == "Amlogic-ne" || "${DEVICE}" == "Amlogic-no" ]]; then
PKG_VERSION="7e11e7aff6d704de4ad8ad7531f597df058099ac"
PKG_SHA256="07978933e040470b1fbb8c887485703f10fb828b583b350e23e834e7b8cee4bc"
else
PKG_VERSION="cb278e367b5e5635be9ebf45fd77fac2ce2fed7a"
PKG_SHA256="74f69c7b1122b178a17840b51a225b8487dfc8bc30dacc9153495e0c88683259"
fi
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
  cd shell/linux
  make CC=${CC} CXX=${CXX} AS=${CC} STRIP=${STRIP} EXTRAFLAGS="-I${PKG_BUILD}/shell/linux-deps/include" platform=odroidc2 reicast.elf
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp reicast.elf ${INSTALL}/usr/bin/reicast
  cp tools/reicast-joyconfig.py ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/bin
  cp -r ${PKG_DIR}/config/* ${INSTALL}/usr/config/
  cp -r ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
 
}
