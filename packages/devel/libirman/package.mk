# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libirman"
PKG_VERSION="0.5.2"
PKG_SHA256="43e58d7cd22b3a4c4dc8dcf8542a269ebcb4d8f6ceea0577b9fc882898f09a47"
PKG_LICENSE="GPL"
PKG_SITE="https://sourceforge.net/projects/libirman"
PKG_URL="http://downloads.sourceforge.net/project/libirman/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd lirc"
PKG_NEED_UNPACK="$(get_pkg_directory lirc)"
PKG_LONGDESC="libirman library for lircd"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic -parallel"

PKG_CONFIGURE_OPTS_TARGET="--disable-swtest"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
