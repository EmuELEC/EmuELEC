# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libusbmuxd"
PKG_VERSION="2.0.2"
PKG_SHA256="cc6a808553da4efa9fa5638be256d5ae020498795d9d260d280b87074e799b20"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libimobiledevice.org"
PKG_URL="https://github.com/libimobiledevice/libusbmuxd/releases/download/${PKG_VERSION}/libusbmuxd-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libplist"
PKG_LONGDESC="A USB multiplex daemon."

PKG_CONFIGURE_OPTS_TARGET="ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes \
                           --enable-static \
                           --disable-shared"

post_configure_target() {
  libtool_remove_rpath libtool
}
