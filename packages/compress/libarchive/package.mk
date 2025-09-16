# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libarchive"
PKG_VERSION="3.6.2"
PKG_SHA256="9e2c1b80d5fbe59b61308fdfab6c79b5021d7ff4ff2489fb12daf0a96a83551d"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libarchive.org"
PKG_URL="https://www.libarchive.org/downloads/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="A multi-format archive and compression library."

PKG_CMAKE_OPTS_TARGET="-DCMAKE_POSITION_INDEPENDENT_CODE=1 \
                       -DENABLE_EXPAT=0 \
                       -DENABLE_ICONV=0 \
                       -DENABLE_LIBXML2=0 \
                       -DENABLE_LZO=1 \
                       -DENABLE_TEST=0 \
                       -DENABLE_COVERAGE=0 \
                       -DENABLE_WERROR=0"

post_makeinstall_target() {
  rm -rf ${INSTALL}

  # delete the shared library as we only want static
  rm ${SYSROOT_PREFIX}/usr/lib/libarchive.so*
}
