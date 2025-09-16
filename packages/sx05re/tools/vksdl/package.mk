# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Diegrosan (https://github.com/Diegrosan)
#

PKG_NAME="vksdl"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 SDL2_ttf freetype"
PKG_LONGDESC="Virtual keyboard daemon for framebuffer devices"
PKG_TOOLCHAIN="manual"

configure_target() {
  cp -f ${PKG_DIR}/virtual_keyboard.cpp ${PKG_BUILD}
}

make_target() {
    ${CXX} ${CXXFLAGS} -std=c++11 virtual_keyboard.cpp -o virtual_keyboard \
        ${LDFLAGS} \
        -lSDL2 \
        -lSDL2_ttf \
        -lSDL2_image \
        -lpng \
        -levdev \
        -lm
}

makeinstall_target() {
    mkdir -p ${INSTALL}/usr/bin
    cp virtual_keyboard ${INSTALL}/usr/bin
}
