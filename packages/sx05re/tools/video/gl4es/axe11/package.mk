# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="axe11"
PKG_VERSION="77813264827823bcbd617ca0f2b2da3e6abb1e7a"
PKG_SHA256="bcdc27316bba492af9f05d25dc07f2a2ac718807393796fc87b2c794bd458e14"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/JohnnyonFlame/axe11"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC="A Proof-of-Concept libX11 Shim for Gamemaker Games to run under Box86 with GL4ES (and the necessary set of hacks on top of it)."

pre_configure_target() {
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile

# Temp copy the X11 header files
  cp -r ${PKG_DIR}/X11 ${SYSROOT_PREFIX}/usr/include
}

post_make_target() {
# Remove X11 header files
  rm -rf ${SYSROOT_PREFIX}/usr/include/X11
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/lib
cp -rf ${PKG_BUILD}/build/libs/*.so ${INSTALL}/usr/lib
}
