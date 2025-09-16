# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bk"
PKG_VERSION="31af5ca5f307991eb596ed411d4d0e955c833421"
PKG_SHA256="f90a9ecc31db054afd0f29690faf88ea6e695025e23526ec110df53b46ef08bc"
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
