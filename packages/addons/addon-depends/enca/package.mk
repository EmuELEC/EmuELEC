# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="enca"
PKG_VERSION="1.19"
PKG_SHA256="3a487eca40b41021e2e4b7a6440b97d822e6532db5464471f572ecf77295e8b8"
PKG_LICENSE="GPL"
PKG_SITE="http://freshmeat.net/projects/enca/"
PKG_URL="http://dl.cihar.com/enca/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Enca detects the encoding of text files, on the basis of knowledge of their language."
PKG_BUILD_FLAGS="+pic"

PKG_MAKEINSTALL_OPTS_TARGET="-C lib"
PKG_CONFIGURE_OPTS_TARGET="ac_cv_file__dev_random=yes \
                           ac_cv_file__dev_urandom=no \
                           ac_cv_file__dev_srandom=no \
                           ac_cv_file__dev_arandom=no \
                           CPPFLAGS="-I${SYSROOT_PREFIX}/usr/include" \
                           --disable-shared \
                           --enable-static \
                           --disable-external \
                           --without-librecode \
                           --disable-rpath \
                           --with-gnu-ld"

pre_make_target() {
  make CC="${HOST_CC}" \
       CPPFLAGS="${HOST_CPPFLAGS}" \
       CFLAGS="${HOST_CFLAGS}" \
       LDFLAGS="${HOST_LDFLAGS}" \
       -C tools
}

post_makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp enca.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
}
