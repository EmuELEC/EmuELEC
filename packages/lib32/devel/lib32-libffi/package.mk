# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libffi"
PKG_VERSION="$(get_pkg_version libffi)"
PKG_NEED_UNPACK="$(get_pkg_directory libffi)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://sourceware.org/${PKG_NAME}/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libffi)/patches"
PKG_LONGDESC="Foreign Function Interface Library."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-debug \
                           --enable-static --disable-shared \
                           --with-pic \
                           --enable-structs \
                           --enable-raw-api \
                           --disable-purify-safety \
                           --with-gnu-ld"

unpack() {
  ${SCRIPTS}/get libffi
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libffi/libffi-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
