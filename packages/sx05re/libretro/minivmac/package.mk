# SPDX-License-Identifier: GPL-2.0-or-later

# EmuELEC package for Mini vMac (libretro-minivmac) core

PKG_NAME="minivmac"
PKG_VERSION="e7fcfef"

PKG_LICENSE="GPL-2.0-only"
PKG_SITE="https://github.com/libretro/libretro-minivmac"
PKG_URL="${PKG_SITE}.git"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="Mini vMac Macintosh II emulator (libretro core)"
PKG_LONGDESC="libretro-minivmac is a libretro port of Mini vMac, a classic Macintosh II emulator."
PKG_TOOLCHAIN="make"

make_target() {
  make -C "${PKG_BUILD}"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/minivmac_libretro.so" \
     "${INSTALL}/usr/lib/libretro/"
}
