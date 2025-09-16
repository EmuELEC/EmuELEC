# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-util-macros"
PKG_VERSION="$(get_pkg_version util-macros)"
PKG_NEED_UNPACK="$(get_pkg_directory util-macros)"
PKG_ARCH="aarch64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_LONGDESC="X.org autoconf utilities such as M4 macros."
PKG_PATCH_DIRS+=" $(get_pkg_directory util-macros)/patches"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get util-macros
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/util-macros/util-macros-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}

pre_configure_target() {
  sed -i 's|^pkgconfigdir = .*|pkgconfigdir = /usr/lib/pkgconfig|' ${PKG_BUILD}/Makefile.am
  sed -i 's|^pkgconfigdir = .*|pkgconfigdir = /usr/lib/pkgconfig|' ${PKG_BUILD}/Makefile.in
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr
}
