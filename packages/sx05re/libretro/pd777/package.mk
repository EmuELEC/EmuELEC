# SPDX-License-Identifier: MIT
# Copyright (C) 2026-present EmuELEC

PKG_NAME="pd777"
PKG_VERSION="8c6d1cb4b0d57f14fb7dc18aa37a8aee79c800a3"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/mittonk/PD777"
PKG_URL="${PKG_SITE}.git"
GET_HANDLER_SUPPORT="git"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="uPD777 libretro core (Epoch Cassette Vision)"
PKG_LONGDESC="Libretro core for the NEC uPD777, as used in the Epoch Cassette Vision (1981)."
PKG_TOOLCHAIN="manual"

PKG_LIBNAME="pd777_libretro.so"
PKG_MAKEDIR="source/libretro"

make_target() {
  make -C ${PKG_BUILD}/${PKG_MAKEDIR} \
    platform=unix \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}" \
    DEBUG=0 \
    -j${CONCURRENCY_MAKE_LEVEL}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/${PKG_MAKEDIR}/${PKG_LIBNAME} ${INSTALL}/usr/lib/libretro/
}