# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC

PKG_NAME="numero"
PKG_VERSION="master"
PKG_SHA256=""
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/nbarkhina/numero"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="TI-83 libretro core (Numero)"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="numero_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="NUMERO_LIB"

pre_make_target() {
  # nothing to configure
  :
}

make_target() {
  make -C ${PKG_BUILD} \
    -f Makefile.libretro \
    platform=unix \
    CC=${CC} \
    CXX=${CXX} \
    AR=${AR} \
    STRIP=${STRIP} \
    DEBUG=0 \
    -j${CPUS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/${PKG_LIBNAME} ${INSTALL}/usr/lib/libretro/
}