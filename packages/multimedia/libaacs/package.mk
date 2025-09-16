# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="libaacs"
PKG_VERSION="0.11.1"
PKG_SHA256="a88aa0ebe4c98a77f7aeffd92ab3ef64ac548c6b822e8248a8b926725bea0a39"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org/developers/libaacs.html"
PKG_URL="https://download.videolan.org/pub/videolan/libaacs/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libgcrypt"
PKG_LONGDESC="Open implementation of the AACS (Advanced Access Content System) specification."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-werror \
                           --disable-extra-warnings \
                           --disable-optimizations \
                           --with-libgcrypt-prefix=${SYSROOT_PREFIX}/usr \
                           --with-libgpg-error-prefix=${SYSROOT_PREFIX}/usr \
                           --with-gnu-ld"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/aacs
    cp -P ../KEYDB.cfg ${INSTALL}/usr/config/aacs
}
