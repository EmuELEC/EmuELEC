# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="sdlterm"
PKG_VERSION="v1"
PKG_LICENSE="Public Domain"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf"
PKG_SHORTDESC="simple SDL2 program to read output of bash scripts"
PKG_TOOLCHAIN="manual"

make_target() {
    SDL_CFLAGS=$($TOOLCHAIN/bin/pkg-config --cflags sdl2)
    SDL_LIBS=$($TOOLCHAIN/bin/pkg-config --libs sdl2)
    SDL_TTF_LIBS=$($TOOLCHAIN/bin/pkg-config --libs SDL2_ttf)
    ${CXX} ${TARGET_CXXFLAGS} sdlterm.cpp -o sdlterm ${SDL_CFLAGS} ${SDL_LIBS} ${SDL_TTF_LIBS} -pthread ${TARGET_LDFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp sdlterm ${INSTALL}/usr/bin
}
