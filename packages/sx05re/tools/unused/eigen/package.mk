# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="eigen"
PKG_VERSION="3.2.10"
PKG_SHA256="760e6656426fde71cc48586c971390816f456d30f0b5d7d4ad5274d8d2cb0a6d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://eigen.tuxfamily.org/index.php?title=Main_Page"
PKG_URL="http://bitbucket.org/eigen/eigen/get/${PKG_VERSION}.tar.bz2"
PKG_SOURCE_DIR="eigen-*"
PKG_DEPENDS_TARGET="toolchain cmake:host"
PKG_SECTION="xmedia/games"
PKG_SHORTDESC="eigen c++ headers"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"
PKG_TOOLCHAIN="configure"

configure_target() {
  SYSROOT_PREFIX=${SYSROOT_PREFIX} cmake -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CONF} \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=/usr/lib \
        -DCMAKE_INSTALL_LIBDIR_NOARCH=/usr/lib \
        -DCMAKE_INSTALL_PREFIX_TOOLCHAIN=${SYSROOT_PREFIX}/usr \
        -DCMAKE_PREFIX_PATH=${SYSROOT_PREFIX}/usr \
        ${EXTRA_CMAKE_OPTS} \
        ..
}
