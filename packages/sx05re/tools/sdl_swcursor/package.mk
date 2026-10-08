# SPDX-License-Identifier: GPL-2.0

PKG_NAME="sdl_swcursor"
PKG_VERSION="1.0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-2.0"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/tools"
PKG_SHORTDESC="LD_PRELOAD software mouse cursor for SDL2 apps on the mali backend"
PKG_TOOLCHAIN="manual"

make_target() {
  ${CC} -shared -fPIC -O2 -o sdl_swcursor.so ${PKG_DIR}/sources/sdl_swcursor.c -ldl
  ${STRIP} sdl_swcursor.so
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  cp sdl_swcursor.so ${INSTALL}/usr/lib/
}
