# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tune-s2"
PKG_VERSION="60cc4aaa70b646d38f2e40251860375283c44816"
PKG_SHA256="e39069a0f2f0930809647052fe1f8c9a13f05af537013b03a99f09ceb9bfb997"
PKG_LICENSE="GPL"
PKG_SITE="https://bitbucket.org/updatelee/tune-s2"
PKG_URL="https://bitbucket.org/CrazyCat/tune-s2/get/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="tune-s2 is a small linux app to be able to tune a dvb devices"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  make install BIND=${INSTALL}/usr/bin
}
