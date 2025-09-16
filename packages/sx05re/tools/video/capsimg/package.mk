# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="capsimg"
PKG_VERSION="5d306bb19bc4382367a1e489fb36768fd224b5e6"
PKG_SHA256="340a4a167a1d457076d133f14ceb3f8fe20773511c3bc37b1dd633e6b81b2da8"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/FrodeSolheim/capsimg"
PKG_URL="https://github.com/FrodeSolheim/capsimg/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SPS Decoder Library 5.1 (formerly IPF Decoder Lib)"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C CAPSImg"

pre_configure_target() {
  ./bootstrap.fs
  ./configure.fs --host=${TARGET_NAME}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
  cp -v  CAPSImg/libcapsimage.so.5.1 ${INSTALL}/usr/lib/
  ln -sf libcapsimage.so.5.1 ${INSTALL}/usr/lib/libcapsimage.so.5
  ln -sf libcapsimage.so.5.1 ${INSTALL}/usr/lib/libcapsimage.so
}
