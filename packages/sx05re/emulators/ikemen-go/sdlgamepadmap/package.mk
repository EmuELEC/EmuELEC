# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Diegrosan (https://github.com/Diegrosan)
#

PKG_NAME="sdlgamepadmap"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain SDL2_ttf SDL2"
PKG_LONGDESC="joystick map for ikemen-go"
PKG_TOOLCHAIN="manual"

configure_target() {
  mkdir -p ${PKG_BUILD}
  cp -rf ${PKG_DIR}/dir/* ${PKG_BUILD}/
}

make_target() {

 ${CC} -s -O3 -o sdl_gamepadmap sdl_gamepadmap.c -lSDL2 -lSDL2_ttf -ljson-c -lm

}

makeinstall_target() {
    
    mkdir -p "$INSTALL/usr/bin"
	
    cp -f "$PKG_BUILD/sdl_gamepadmap" "$INSTALL/usr/bin/sdl_gamepadmap"
    
	chmod +x "$INSTALL/usr/bin/sdl_gamepadmap"

}

