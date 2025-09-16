# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="libbdplus"
PKG_VERSION="0.2.0"
PKG_SHA256="b93eea3eaef33d6e9155d2c34b068c505493aa5a4936e63274f4342ab0f40a58"
PKG_LICENSE="GPL"
PKG_SITE="https://www.videolan.org/developers/libbdplus.html"
PKG_URL="http://download.videolan.org/pub/videolan/${PKG_NAME}/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libgcrypt libgpg-error"
PKG_LONGDESC="libbdplus is a research project to implement the BD+ System Specifications."

PKG_CONFIGURE_OPTS_TARGET="--disable-werror \
                           --disable-extra-warnings \
                           --disable-optimizations \
                           --with-libgcrypt-prefix=${SYSROOT_PREFIX}/usr \
                           --with-gpg-error-prefix=${SYSROOT_PREFIX}/usr \
                           --with-gnu-ld"

if [ "${BLURAY_AACS_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libaacs"
  PKG_CONFIGURE_OPTS_TARGET+=" --with-libaacs"
else
  PKG_CONFIGURE_OPTS_TARGET+=" --without-libaacs"
fi

post_configure_target() {
  libtool_remove_rpath libtool
}
