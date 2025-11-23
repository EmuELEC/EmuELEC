# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="amremote"
PKG_VERSION="c979ec379706e023471f28fc49c92633ab9a370a"
PKG_SHA256="8d4c38b51758538069907f280d3e0d50ddb2e7b79492c4e2b1465d2ee67448e3"
PKG_LICENSE="other"
PKG_SITE="http://www.amlogic.com"
PKG_URL="https://github.com/CoreELEC/amremote/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain usbutils"
PKG_LONGDESC="amremote - IR remote configuration utility for Amlogic-based devices"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp remotecfg ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib/coreelec
    cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/lib/coreelec
}

post_install() {
  enable_service remote-config.service
}
