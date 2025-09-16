# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="blindscan-s2"
PKG_VERSION="28c50c6c3789ea3fcc11b992723d652378c0e925"
PKG_SHA256="ac766d04bf1a32cf9c74a7ba12070ddf7c4c15bc0a94a0da60d104f2b76f0f9e"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/OpenVisionE2/blindscan-s2/"
PKG_URL="https://github.com/OpenVisionE2/blindscan-s2/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="blindscan-s2 is a program to blindscan digital satellite signals"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  make install BIND=${INSTALL}/usr/bin
}
