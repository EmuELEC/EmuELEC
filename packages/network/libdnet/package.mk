# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libdnet"
PKG_VERSION="1.14"
PKG_SHA256="592599c54a57102a177270f3a2caabda2c2ac7768b977d7458feba97da923dfe"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/ofalk/libdnet"
PKG_URL="https://github.com/ofalk/libdnet/archive/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A simplified, portable interface to several low-level networking routines"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_func_strlcat=no \
                           ac_cv_func_strlcpy=no \
                           --enable-static \
                           --disable-shared \
                           --disable-python"

pre_configure_target() {
  export CFLAGS+=" -I${PKG_BUILD}/include"
}

post_makeinstall_target() {
  cp ${SYSROOT_PREFIX}/usr/bin/dnet-config \
     ${TOOLCHAIN}/bin/dnet-config
}
