# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="ccleste"
PKG_VERSION="261d96f15af430b8111abc7a5250229246654f52"
PKG_SITE="https://github.com/lemon32767/ccleste"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer"
PKG_SHORTDESC="Celeste Classic C source port for 3DS and PC."
PKG_TOOLCHAIN="make"

pre_configure_target() {
 sed -i "s|=sdl2-config|=${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/ccleste
  cp ${PKG_BUILD}/ccleste ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/data ${INSTALL}/usr/config/emuelec/configs/ccleste
}
