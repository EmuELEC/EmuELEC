# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="szap-s2"
PKG_VERSION="69ff3584caf9b46f7a551b39b9f9956f8461377c"
PKG_SHA256="eea8d99d2d5d6403d624acdd9df908a2dd7767dd5469b44e9a281ff863096b32"
PKG_LICENSE="GPL"
PKG_SITE="https://bitbucket.org/updatelee/tune-s2"
PKG_URL="https://bitbucket.org/CrazyCat/szap-s2/get/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="szap-s2 is a simple zapping tool for the Linux DVB S2 API"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  make install BIND=${INSTALL}/usr/bin
}
