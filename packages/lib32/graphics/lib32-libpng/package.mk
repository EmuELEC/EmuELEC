# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libpng"
PKG_VERSION="$(get_pkg_version libpng)"
PKG_NEED_UNPACK="$(get_pkg_directory libpng)"
PKG_ARCH="aarch64"
PKG_LICENSE="LibPNG2"
PKG_SITE="http://www.libpng.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib"
PKG_PATCH_DIRS+=" $(get_pkg_directory libpng)/patches"
PKG_LONGDESC="An extensible file format for the lossless, portable, well-compressed storage of raster images."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32 +pic +pic:host"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_lib_z_zlibVersion=yes \
                           --enable-static \
                           --enable-shared"

unpack() {
  ${SCRIPTS}/get libpng
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libpng/libpng-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_target() {
  export CPPFLAGS="${CPPFLAGS} -I${SYSROOT_PREFIX}/usr/include"
}

post_makeinstall_target() {
  sed -e "s:\([\"'= ]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" \
      -e "s:libs=\"-lpng16\":libs=\"-lpng16 -lz\":g" \
      -i ${SYSROOT_PREFIX}/usr/bin/libpng*-config

  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
