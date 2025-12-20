# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="amremote"
PKG_VERSION="455eb8ef8507acf899d4723c022de1c981bb697e"
PKG_SHA256="985bd796995cd756b0edcc34a88e31392a21c04b6c9a4a46e20f4bca19ab1511"
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
