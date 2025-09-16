# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2017 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libaio"
PKG_VERSION="0.3.113"
PKG_SHA256="716c7059703247344eb066b54ecbc3ca2134f0103307192e6c2b7dab5f9528ab"
PKG_LICENSE="GPL"
PKG_SITE="https://pagure.io/libaio"
PKG_URL="https://pagure.io/${PKG_NAME}/archive/${PKG_NAME}-${PKG_VERSION}/${PKG_NAME}-${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Kernel Asynchronous I/O (AIO) Support for Linux."

make_target() {
  make -C src
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -PR src/libaio.a ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -PR src/libaio.h ${SYSROOT_PREFIX}/usr/include
}
