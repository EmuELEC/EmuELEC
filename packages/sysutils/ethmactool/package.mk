# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ethmactool"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_LONGDESC="ethmactool: udev rule for obtaining real MAC address or creating a persistent MAC from the CPU serial"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/ethmactool-config ${INSTALL}/usr/bin
}

post_install() {
  enable_service ethmactool-config.service
}
