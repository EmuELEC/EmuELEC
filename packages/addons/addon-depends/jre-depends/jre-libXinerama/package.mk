# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

. $(get_pkg_directory libXinerama)/package.mk

PKG_NAME="jre-libXinerama"
PKG_LONGDESC="libXinerama for JRE"
PKG_URL=""
PKG_DEPENDS_UNPACK+=" libXinerama"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET+=" --disable-static --enable-shared"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME:4}/${PKG_NAME:4}-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}
