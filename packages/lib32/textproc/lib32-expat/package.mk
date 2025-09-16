# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-expat"
PKG_VERSION="$(get_pkg_version expat)"
PKG_NEED_UNPACK="$(get_pkg_directory expat)"
PKG_LICENSE="OSS"
PKG_SITE="http://expat.sourceforge.net/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory expat)/patches"
PKG_LONGDESC="Expat is an XML parser library written in C."
PKG_BUILD_FLAGS="lib32"

PKG_CMAKE_OPTS_TARGET="-DEXPAT_BUILD_DOCS=OFF \
                       -DEXPAT_BUILD_TOOLS=OFF \
                       -DEXPAT_BUILD_EXAMPLES=OFF \
                       -DEXPAT_BUILD_TESTS=OFF \
                       -DEXPAT_SHARED_LIBS=ON"

unpack() {
  ${SCRIPTS}/get expat
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/expat/expat-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
