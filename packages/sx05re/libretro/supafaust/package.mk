# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="supafaust"
PKG_VERSION="e25f66765938d33f9ad5850e8d6cd597e55b7299"
PKG_SHA256="0b0ff644b780d1565e8f097998f371b1a4255213846c2082d8e8c143d0868ef1"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/supafaust"
PKG_URL="https://github.com/libretro/supafaust/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="SNES emulator for multicore ARM Cortex A7, A9, A15, A53 Linux platforms"
PKG_LONGDESC="SNES emulator optimized for multicore ARM processors."
PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

PKG_LIBNAME="mednafen_supafaust_libretro.so"
PKG_LIBVAR="SUPAFAUST_LIB"

make_target() {
  make
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v mednafen_supafaust_libretro.so ${INSTALL}/usr/lib/libretro/
 
}