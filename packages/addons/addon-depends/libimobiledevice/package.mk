# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libimobiledevice"
PKG_VERSION="1.3.0"
PKG_SHA256="53f2640c6365cd9f302a6248f531822dc94a6cced3f17128d4479a77bd75b0f6"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libimobiledevice.org"
PKG_URL="https://github.com/libimobiledevice/libimobiledevice/releases/download/${PKG_VERSION}/libimobiledevice-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libusbmuxd openssl"
PKG_LONGDESC="A cross-platform software library that talks the protocols to support Apple devices."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --without-cython \
                           --disable-largefile"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  mkdir -p "${SYSROOT_PREFIX}/usr/include/lib/libimobiledevice"
    cp ${PKG_BUILD}/common/utils.h "${SYSROOT_PREFIX}/usr/include/libimobiledevice"
}
