# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-nettle"
PKG_VERSION="$(get_pkg_version nettle)"
PKG_NEED_UNPACK="$(get_pkg_directory nettle)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL2"
PKG_SITE="http://www.lysator.liu.se/~nisse/nettle"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-gmp"
PKG_PATCH_DIRS+=" $(get_pkg_directory nettle)/patches"
PKG_LONGDESC="A low-level cryptographic library."
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-documentation \
                           --disable-openssl"

if target_has_feature neon; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-arm-neon"
fi

unpack() {
  ${SCRIPTS}/get nettle
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/nettle/nettle-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
