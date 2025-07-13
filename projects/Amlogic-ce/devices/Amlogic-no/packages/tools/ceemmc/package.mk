# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="ceemmc"
PKG_VERSION="bc480ecc38077c10f825b089564f42a7ed1f5c0c"
PKG_SHA256="aca90a9faaeee54d781b4d131b87a01cfa656a9db94e7b458f44608bab4c4e01"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_SOURCE_NAME="ceemmc-aarch64-${PKG_VERSION}.tar.xz"
PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Tool to install CoreELEC on internal eMMC"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
    install -m 0755 ceemmc ${INSTALL}/usr/sbin/ceemmc
}
