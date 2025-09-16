# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji ()

PKG_NAME="lib32-libpciaccess"
PKG_VERSION="$(get_pkg_version libpciaccess)"
PKG_NEED_UNPACK="$(get_pkg_directory libpciaccess)"
PKG_LICENSE="OSS"
PKG_SITE="http://freedesktop.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-util-macros lib32-zlib"
PKG_LONGDESC="X.org libpciaccess library."
PKG_PATCH_DIRS+=" $(get_pkg_directory libpciaccess)/patches"
PKG_BUILD_FLAGS="lib32"
PKG_TOOLCHAIN="autotools"


PKG_CONFIGURE_OPTS_TARGET="ac_cv_header_asm_mtrr_h=set \
                           --with-pciids-path=/usr/share \
                           --with-zlib "

unpack() {
  ${SCRIPTS}/get libpciaccess
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libpciaccess/libpciaccess-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_target() {
  CFLAGS+=" -D_LARGEFILE64_SOURCE"
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
