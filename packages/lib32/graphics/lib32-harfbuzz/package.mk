# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-harfbuzz"
PKG_VERSION="$(get_pkg_version harfbuzz)"
PKG_NEED_UNPACK="$(get_pkg_directory harfbuzz)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://www.freedesktop.org/wiki/Software/HarfBuzz"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-cairo lib32-freetype lib32-glib"
PKG_PATCH_DIRS+=" $(get_pkg_directory harfbuzz)/patches"
PKG_LONGDESC="HarfBuzz is an OpenType text shaping engine."
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="lib32"

PKG_MESON_OPTS_TARGET="-Dbenchmark=disabled \
                       -Dcairo=enabled \
                       -Ddocs=disabled \
                       -Dfreetype=enabled \
                       -Dglib=enabled \
                       -Dgobject=disabled \
                       -Dgraphite=disabled \
                       -Dicu=disabled \
                       -Dtests=disabled"

unpack() {
  ${SCRIPTS}/get harfbuzz
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/harfbuzz/harfbuzz-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
