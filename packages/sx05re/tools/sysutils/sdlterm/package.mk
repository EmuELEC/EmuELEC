# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="sdlterm"
PKG_VERSION="v1"
PKG_LICENSE="Public Domain"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf"
PKG_SHORTDESC="simple SDL2 program to read output of bash scripts"
PKG_TOOLCHAIN="manual"

make_target() {
    ${CXX} ${CXXFLAGS} -std=c++11 sdlterm.cpp -o sdlterm ${LDFLAGS} -lSDL2 -lSDL2_ttf -pthread
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp sdlterm ${INSTALL}/usr/bin
}
