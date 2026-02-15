# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="mojozork"
PKG_VERSION="517ccff5ad6a811f948fadc0489b45c32f177c42"
PKG_SHA256=""
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/icculus/mojozork"
PKG_URL="https://github.com/icculus/mojozork/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MojoZork: Z-Machine implementation as libretro core"
PKG_TOOLCHAIN="manual"

PKG_LIBNAME="mojozork_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"

make_target() {
  cd ${PKG_BUILD}
  ${CC} -o ${PKG_LIBNAME} mojozork-libretro.c -shared -fPIC ${CFLAGS} ${LDFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_LIBPATH} ${INSTALL}/usr/lib/libretro/
}