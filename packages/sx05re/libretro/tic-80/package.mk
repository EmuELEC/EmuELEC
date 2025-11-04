# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="tic-80"
PKG_VERSION="a2c875f7275541e7724199ce8e504fb578b819a6"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nesbox/TIC-80"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="TIC-80 is a fantasy computer for making, playing and sharing tiny games."
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DBUILD_LIBRETRO=ON \
					   -DBUILD_PLAYER=ON \
                       -DBUILD_SDL=ON \
                       -DBUILD_WITH_RUBY=OFF \
                       -DBUILD_WITH_YUE=OFF \
                       -DCMAKE_BUILD_TYPE=Release \
                       -DBUILD_WITH_JANET=Off  \
                       -DBUILD_WITH_ALL=On \
                       -DBUILD_STATIC=On"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/tic80_libretro.so ${INSTALL}/usr/lib/libretro/tic80_libretro.so
}
