# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="emmctool"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_LONGDESC="emmctool: simple tool for writing LibreELEC images to emmc on supported box/board devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/emmctool ${INSTALL}/usr/bin
}
