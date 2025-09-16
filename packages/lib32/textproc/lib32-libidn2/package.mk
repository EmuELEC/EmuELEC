# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libidn2"
PKG_VERSION="$(get_pkg_version libidn2)"
PKG_NEED_UNPACK="$(get_pkg_directory libidn2)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL3"
PKG_SITE="https://www.gnu.org/software/libidn/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libidn2)/patches"
PKG_LONGDESC="Free software implementation of IDNA2008, Punycode and TR46."
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-doc \
                           --enable-shared \
                           --disable-static"

unpack() {
  ${SCRIPTS}/get libidn2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libidn2/libidn2-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
