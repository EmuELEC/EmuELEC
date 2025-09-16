# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-gmp"
PKG_VERSION="$(get_pkg_version gmp)"
PKG_NEED_UNPACK="$(get_pkg_directory gmp)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPLv3+"
PKG_SITE="http://gmplib.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory gmp)/patches"
PKG_LONGDESC="A library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating point numbers."
PKG_BUILD_FLAGS="lib32 +pic:host"

PKG_CONFIGURE_OPTS_HOST="--enable-cxx --enable-static --disable-shared"

unpack() {
  ${SCRIPTS}/get gmp
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/gmp/gmp-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_host() {
  export CPPFLAGS="${CPPFLAGS} -fexceptions"
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
