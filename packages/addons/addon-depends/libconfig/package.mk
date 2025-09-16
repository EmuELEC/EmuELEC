# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libconfig"
PKG_VERSION="1.7.3"
PKG_SHA256="68757e37c567fd026330c8a8449aa5f9cac08a642f213f2687186b903bd7e94e"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/hyperrealm/libconfig"
PKG_URL="https://github.com/hyperrealm/libconfig/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A C/C++ configuration file library."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --disable-doc \
                           --disable-examples \
                           --disable-tests \
                           --with-sysroot=${SYSROOT_PREFIX}"

pre_configure_target() {
  cd ..
  rm -rf .${TARGET_NAME}
}
