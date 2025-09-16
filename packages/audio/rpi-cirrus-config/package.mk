# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rpi-cirrus-config"
PKG_VERSION="0.0.2"
PKG_SHA256="cc11c47f1f2b6d5e72dcdea828ba57e0dcaf74161f675a4a9f395054f5d82d31"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/HiassofT/rpi-cirrus-config"
PKG_URL="https://github.com/HiassofT/rpi-cirrus-config/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="alsa-utils"
PKG_LONGDESC="Config scripts for the Wolfson/Cirrus Logic audio card"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/udev
  install -m 0755 ${PKG_DIR}/scripts/rpi-cirrus-config ${INSTALL}/usr/lib/udev/rpi-cirrus-config

  mkdir -p ${INSTALL}/usr/share/alsa/cards
  cp alsa/RPiCirrus.conf ${INSTALL}/usr/share/alsa/cards

  mkdir -p ${INSTALL}/usr/lib/alsa
  cp mixer-scripts/rpi-cirrus-functions.sh ${INSTALL}/usr/lib/alsa

  mkdir -p ${INSTALL}/usr/config
  cp -PR ${PKG_DIR}/config/* ${INSTALL}/usr/config
}
