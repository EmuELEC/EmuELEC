# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bcmstat"
PKG_VERSION="0.5.5"
PKG_SHA256="faf21907c183ec45ca5a7737a220d3275d24a7d8a387344ed1562849b2d67f27"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/MilhouseVH/bcmstat"
PKG_URL="https://github.com/MilhouseVH/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Raspberry Pi monitoring script"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -PRv bcmstat.sh ${INSTALL}/usr/bin
    chmod +x ${INSTALL}/usr/bin/*
}
