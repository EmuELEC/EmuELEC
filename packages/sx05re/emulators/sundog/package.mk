# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sundog"
PKG_VERSION="64d854dde3fc5df250a9c108c92ec697847ba8af"
PKG_SHA256="8be3593de48d07701f67d505b1ccf7db4613fd17eade186fa3c6fd8049367622"
PKG_ARCH="any"
PKG_SITE="https://github.com/laanwj/sundog"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="A port of the Atari ST game SunDog: Frozen Legacy (1984) by FTL software "
PKG_TOOLCHAIN="make"

pre_configure_target() {
  cd src
  PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src sundog"
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
  sed -i "s|-lreadline|-lreadline -lncurses|g" Makefile
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
	cp ${PKG_BUILD}/src/sundog ${INSTALL}/usr/bin
}
