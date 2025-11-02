# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present AmberELEC (https://github.com/AmberELEC)
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="zmusic"
PKG_VERSION="7476a189755d2665b24a58182640752b82b3a66d"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ZDoom/ZMusic"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_HOST="toolchain:host glib:host"
PKG_DEPENDS_TARGET="toolchain zmusic:host"
PKG_LONGDESC="GZDoom's music system as a standalone library"
PKG_TOOLCHAIN="cmake-make"

pre_build_host() {
  HOST_CMAKE_OPTS=""
}

make_host() {
  mkdir ${PKG_BUILD}/build_host
  cd ${PKG_BUILD}/build_host
  cmake -DCMAKE_BUILD_TYPE=Release ..
  cmake --build .
}

make_target() {
  mkdir ${PKG_BUILD}/build_target
  cd ${PKG_BUILD}/build_target
  cmake -DCMAKE_BUILD_TYPE=Release ..
  cmake --build .
}

makeinstall_host() {
: #no
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  cp -f ${PKG_BUILD}/build_target/source/libzmusic* ${INSTALL}/usr/lib/
}
