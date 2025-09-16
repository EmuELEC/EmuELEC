# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="amremote"
PKG_LICENSE="other"
PKG_SITE="http://www.amlogic.com"
PKG_DEPENDS_TARGET="toolchain usbutils"
PKG_LONGDESC="amremote - IR remote configuration utility for Amlogic-based devices"

case "${LINUX}" in
  amlogic-4.9)
    PKG_VERSION="1db130a0ccd47f6b5c3d1dffab1e89613b796a8c"
    PKG_SHA256="5b96f2a1dd03200909eed749f5d97d1d02ee7fc8ac92d8fce6b5d6772ee642dc"
    PKG_URL="https://github.com/CoreELEC/amremote/archive/${PKG_VERSION}.tar.gz"
    ;;
  amlogic-5.4)
    PKG_VERSION="455eb8ef8507acf899d4723c022de1c981bb697e"
    PKG_SHA256="985bd796995cd756b0edcc34a88e31392a21c04b6c9a4a46e20f4bca19ab1511"
    PKG_URL="https://github.com/CoreELEC/amremote/archive/${PKG_VERSION}.tar.gz"
    ;;
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp remotecfg ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib/coreelec
    cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/lib/coreelec
}

post_install() {
  enable_service remote-config.service
}
