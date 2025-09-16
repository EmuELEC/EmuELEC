# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

. $(get_pkg_directory harfbuzz)/package.mk

PKG_NAME="harfbuzz-icu"
PKG_URL=""
PKG_DEPENDS_TARGET+=" icu"
PKG_LONGDESC="HarfBuzz with icu"
PKG_DEPENDS_CONFIG="icu"
PKG_DEPENDS_UNPACK+=" harfbuzz"
PKG_BUILD_FLAGS="-sysroot"

PKG_MESON_OPTS_TARGET="-Dbenchmark=disabled \
                       -Dcairo=enabled \
                       -Ddocs=disabled \
                       -Dfreetype=enabled \
                       -Dglib=enabled \
                       -Dgobject=disabled \
                       -Dgraphite=disabled \
                       -Dicu=enabled \
                       -Dtests=disabled"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME:0:8}/${PKG_NAME:0:8}-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}
