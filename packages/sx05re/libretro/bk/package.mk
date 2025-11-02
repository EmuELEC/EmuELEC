# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bk"
PKG_VERSION="f95d929c8eca6c85075cd5c56a08aac9c58f3802"
PKG_SHA256="7ed9976abe5c235061a44884346426509231d1237c9b7ff23e8a7aa6894fcf5d"
PKG_LICENSE="NTP"
PKG_SITE="https://github.com/libretro/bk-emulator"
PKG_URL="https://github.com/libretro/bk-emulator/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC=""

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {


  mkdir -p ${INSTALL}/usr/lib/libretro

  wget -O ${INSTALL}/usr/lib/libretro/bk_libretro.info https://raw.githubusercontent.com/libretro/libretro-super/master/dist/info/bk_libretro.info

  cp ${PKG_BUILD}/bk_libretro.so ${INSTALL}/usr/lib/libretro/
  
}
