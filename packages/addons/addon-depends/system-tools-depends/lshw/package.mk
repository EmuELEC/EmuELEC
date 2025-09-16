# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lshw"
PKG_VERSION="02.19.2"
PKG_SHA256="9bb347ac87142339a366a1759ac845e3dbb337ec000aa1b99b50ac6758a80f80"
PKG_LICENSE="GPL"
PKG_SITE="http://ezix.org/project/wiki/HardwareLiSter"
PKG_URL="http://ezix.org/software/files/lshw-B.${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A small tool to provide detailed information on the hardware configuration of the machine."
PKG_BUILD_FLAGS="-sysroot"

make_target() {
  export VERSION="B.${PKG_VERSION}"
  make CXX=${CXX} -C src/
}
