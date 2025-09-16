# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xf86-video-ati"
PKG_VERSION="19.1.0"
PKG_SHA256="659f5a1629eea5f5334d9b39b18e6807a63aa1efa33c1236d9cc53acbb223c49"
PKG_ARCH="x86_64"
PKG_LICENSE="OSS"
PKG_SITE="https://www.x.org/wiki/RadeonFeature/"
PKG_URL="http://xorg.freedesktop.org/archive/individual/driver/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain xorg-server"
PKG_LONGDESC="ATI/AMD Radeon video driver for the Xorg X server."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-glamor \
                           --with-xorg-module-dir=${XORG_PATH_MODULES}"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/etc/X11
    cp ${PKG_DIR}/config/*.conf ${INSTALL}/etc/X11
}
