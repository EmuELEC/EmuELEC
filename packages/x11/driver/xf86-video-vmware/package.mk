# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xf86-video-vmware"
PKG_VERSION="13.4.0"
PKG_SHA256="aed31ee5ed5ecc6e2226705383e7ad06f7602c1376a295305f376b17af3eb81a"
PKG_ARCH="x86_64"
PKG_LICENSE="OSS"
PKG_SITE="https://www.vmware.com"
PKG_URL="https://xorg.freedesktop.org/releases/individual/driver/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain mesa libX11 xorg-server"
PKG_LONGDESC="xf86-video-vmware: The Xorg driver for vmware video"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-vmwarectrl-client \
                           --with-xorg-module-dir=${XORG_PATH_MODULES}"

post_configure_target() {
  libtool_remove_rpath libtool
}
