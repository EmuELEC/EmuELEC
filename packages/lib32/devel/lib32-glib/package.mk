# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-glib"
PKG_VERSION="$(get_pkg_version glib)"
PKG_NEED_UNPACK="$(get_pkg_directory glib)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="https://www.gtk.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-pcre2 lib32-zlib lib32-libffi Python3:host lib32-util-linux"
PKG_PATCH_DIRS+=" $(get_pkg_directory glib)/patches"
PKG_LONGDESC="A library which includes support routines for C such as lists, trees, hashes, memory allocation."
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="lib32"

PKG_MESON_OPTS_TARGET="-Ddefault_library=shared \
                       -Dinstalled_tests=false \
                       -Dselinux=disabled \
                       -Dxattr=true \
                       -Dgtk_doc=false \
                       -Dman=false \
                       -Ddtrace=false \
                       -Dsystemtap=false \
                       -Dbsymbolic_functions=true \
                       -Dforce_posix_threads=true \
                       -Dtests=false"

unpack() {
  ${SCRIPTS}/get glib
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/glib/glib-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
