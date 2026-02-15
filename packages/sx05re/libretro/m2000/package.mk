# SPDX-License-Identifier: GPL-2.0-or-later
# EmuELEC package for M2000 libretro core (Philips P2000T)

PKG_NAME="m2000"
PKG_VERSION="0.9.4"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/p2000t/M2000"


PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_SOURCE_DIR="M2000-${PKG_VERSION}"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="Philips P2000T (M2000) libretro core"
PKG_LONGDESC="M2000 is an emulator for the Philips P2000T home computer, here built as a libretro core."
PKG_TOOLCHAIN="make"

make_target() {
  make -C "${PKG_BUILD}/src/libretro" \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}" \
    platform=unix
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/src/libretro/m2000_libretro.so" \
     "${INSTALL}/usr/lib/libretro/"
}
