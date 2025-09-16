# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bzip2"
PKG_VERSION="1.0.8"
PKG_SHA256="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
PKG_LICENSE="GPL"
PKG_SITE="https://sourceware.org/bzip2/"
PKG_URL="https://sourceware.org/pub/bzip2/bzip2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A high-quality bzip2 data compressor."
PKG_BUILD_FLAGS="+pic +pic:host"

pre_build_host() {
  mkdir -p ${PKG_BUILD}/.${HOST_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}
}

make_host() {
  cd ${PKG_BUILD}/.${HOST_NAME}
  make -f Makefile-libbz2_so CC=${HOST_CC} CFLAGS="${CFLAGS}"
}

makeinstall_host() {
  make install PREFIX=${TOOLCHAIN}
}

pre_build_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

pre_make_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  sed -e "s,ln -s (lib.*),ln -snf \$${1}; ln -snf libbz2.so.${PKG_VERSION} libbz2.so,g" -i Makefile-libbz2_so
}

make_target() {
  make -f Makefile-libbz2_so CC=${CC} CFLAGS="${CFLAGS}"
}

post_make_target() {
  ln -snf libbz2.so.1.0 libbz2.so
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp bzlib.h ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -P libbz2.so* ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${INSTALL}/usr/lib
    cp -P libbz2.so* ${INSTALL}/usr/lib
}
