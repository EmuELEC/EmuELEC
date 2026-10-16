# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="geartowns"
PKG_VERSION="f36883a91c9a068f7cd228b37a89e2444497e5c8"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/drhelius/Geartowns"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Geartowns - Fujitsu FM Towns emulator (libretro core)"
PKG_TOOLCHAIN="make"

make_target() {
  make -C platforms/libretro platform=unix
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp platforms/libretro/geartowns_libretro.so ${INSTALL}/usr/lib/libretro/
}
