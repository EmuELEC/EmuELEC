# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gdb"
PKG_VERSION="12.1"
PKG_SHA256="0e1793bf8f2b54d53f46dea84ccfd446f48f81b297b28c4f7fc017b818d69fed"
PKG_LICENSE="GPL"
PKG_SITE="http://www.gnu.org/software/gdb/"
PKG_URL="https://ftp.gnu.org/gnu/gdb/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib ncurses expat gmp"
PKG_DEPENDS_HOST="toolchain:host zlib:host ncurses:host expat:host gmp:host"
PKG_LONGDESC="GNU Project debugger, allows you to see what is going on inside another program while it executes."
PKG_BUILD_FLAGS="+size"

PKG_CONFIGURE_OPTS_COMMON="bash_cv_have_mbstate_t=set \
                           --disable-shared \
                           --enable-static \
                           --with-auto-load-safe-path=/ \
                           --with-python=no \
                           --with-guile=no \
                           --with-mpfr=no \
                           --with-intel-pt=no \
                           --with-babeltrace=no \
                           --with-expat=yes \
                           --disable-source-highlight \
                           --disable-nls \
                           --disable-rpath \
                           --disable-sim \
                           --without-x \
                           --disable-tui \
                           --disable-libada \
                           --without-lzma \
                           --disable-libquadmath \
                           --disable-libquadmath-support \
                           --enable-libada \
                           --enable-libssp \
                           --disable-werror"

PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_COMMON} \
                           --with-libexpat-prefix=${SYSROOT_PREFIX}/usr \
                           --with-libgmp-prefix=${SYSROOT_PREFIX}/usr"

PKG_CONFIGURE_OPTS_HOST="${PKG_CONFIGURE_OPTS_COMMON} \
                         --target=${TARGET_NAME}"

pre_configure_target() {
  CC_FOR_BUILD="${HOST_CC}"
  CFLAGS_FOR_BUILD="${HOST_CFLAGS}"
}

makeinstall_target() {
  make DESTDIR=${INSTALL} install
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/share/gdb/python
}
