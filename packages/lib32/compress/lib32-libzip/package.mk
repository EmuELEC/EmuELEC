# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team CoreELEC (https://coreelec.org)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libzip"
PKG_VERSION="$(get_pkg_version libzip)"
PKG_NEED_UNPACK="$(get_pkg_directory libzip)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://www.nih.at/libzip/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib lib32-zstd"
PKG_PATCH_DIRS+=" $(get_pkg_directory libzip)/patches"
PKG_LONGDESC="A C library for reading, creating, and modifying zip archives."
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get libzip
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libzip/libzip-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
