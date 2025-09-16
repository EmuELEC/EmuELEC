# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-zlib"
PKG_VERSION="$(get_pkg_version zlib)"
PKG_NEED_UNPACK="$(get_pkg_directory zlib)"
PKG_ARCH="aarch64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.zlib.net"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain zlib"
PKG_LONGDESC="A general purpose (ZIP) data compression library."
PKG_TOOLCHAIN="cmake-make"
PKG_PATCH_DIRS+=" $(get_pkg_directory zlib)/patches"
PKG_BUILD_FLAGS="lib32"

PKG_CMAKE_OPTS_TARGET="-DINSTALL_PKGCONFIG_DIR=/usr/lib/pkgconfig"

unpack() {
  ${SCRIPTS}/get zlib
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/zlib/zlib-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
