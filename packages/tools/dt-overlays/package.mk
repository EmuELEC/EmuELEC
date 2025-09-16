# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dt-overlays"
PKG_VERSION="4352d87db6e85d285673359e80cce87d5e025c64"
PKG_SHA256="754a0c37a41f8e5d9d179eb1df40b84eb48c0a505a37e39fed5f1ceb35e8e120"
PKG_LICENSE="GPLv2+ or MIT"
PKG_SITE="https://github.com/LibreELEC/dt-overlays"
PKG_URL="https://github.com/LibreELEC/dt-overlays/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="dtc:host"
PKG_LONGDESC="The Device Tree Overlays"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/overlays
    cp -p overlays/*/*.dtbo ${INSTALL}/usr/share/bootloader/overlays
}
