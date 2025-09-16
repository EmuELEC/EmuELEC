# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="rs97-commander-sdl2"
PKG_VERSION="ad4f01b14a2fde33897167f18daa7218c13e5b52"
PKG_SHA256="175357346bae41e827de5cf79e752ed438eaae7dba82d812f042dd05fb146b45"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/EmuELEC/rs97-commander-sdl2"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf freetype"
PKG_SECTION="tools"
PKG_SHORTDESC="Two-pane commander for RetroFW and RG-350 (fork of Dingux Commander)"

pre_configure_target() {
sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|" Makefile
sed -i "s|CC=g++|CC=${CXX}|" Makefile

OGA=0

if [[ "${DEVICE}" == "OdroidGoAdvance" || "${DEVICE}" == "GameForce" ]]; then
	OGA=1
fi

PKG_MAKE_OPTS_TARGET=" ODROIDGO=${OGA} CC=${CXX}"
	
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/fm
  cp DinguxCommander ${INSTALL}/usr/bin/
  cp -rf res ${INSTALL}/usr/config/emuelec/configs/fm/
}
