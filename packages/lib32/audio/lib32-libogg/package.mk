# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libogg"
PKG_VERSION="$(get_pkg_version libogg)"
PKG_NEED_UNPACK="$(get_pkg_directory libogg)"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD"
PKG_SITE="https://www.xiph.org/ogg/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libogg)/patches"
PKG_LONGDESC="Libogg contains necessary functionality to create, decode, and work with Ogg bitstreams."
PKG_BUILD_FLAGS="lib32 +pic"

PKG_CMAKE_OPTS_TARGET="-DINSTALL_DOCS=OFF"

unpack() {
  ${SCRIPTS}/get libogg
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libogg/libogg-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
