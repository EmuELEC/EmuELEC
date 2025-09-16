# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nss-mdns"
PKG_VERSION="0.15.1"
PKG_SHA256="2d1b8de2e9ed5526f51c8bb627b719c07668465b5315787e7cfeed776ab90b9a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lathiat/nss-mdns"
PKG_URL="https://github.com/lathiat/nss-mdns/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain avahi"
PKG_LONGDESC="A plugin for nss to allow name resolution via Multicast DNS."
PKG_TOOLCHAIN="autotools"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/etc
  cp ${PKG_DIR}/config/nsswitch.conf ${INSTALL}/etc/nsswitch.conf
}
