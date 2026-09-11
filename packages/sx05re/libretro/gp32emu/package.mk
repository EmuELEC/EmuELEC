# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC/EmuELEC)

PKG_NAME="gp32emu"
PKG_VERSION="9ca3a72fac79eb57dd16ec21f3756e243e4a579d"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/gameblabla/gp32emu"
PKG_URL="${PKG_SITE}/archive/refs/heads/main.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="GP32 libretro core"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  cd ${PKG_BUILD}
}

make_target() {
  make -f Makefile.libretro \
    CC="${CC}" \
    AR="${AR}" \
    CFLAGS="${CFLAGS} -std=c11 -fPIC" \
    GP32EMU_ENABLE_THREADS=0 \
    clean all
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp gp32emu_libretro.so ${INSTALL}/usr/lib/libretro/

  mkdir -p ${INSTALL}/usr/share/libretro/info
  cp ${PKG_BUILD}/gp32emu_libretro.info \
     ${INSTALL}/usr/share/libretro/info/
}
