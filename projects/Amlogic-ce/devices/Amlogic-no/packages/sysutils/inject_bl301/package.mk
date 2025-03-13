# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="inject_bl301"
PKG_VERSION="67cf0989180b73c3d9189278f90bc5bb8e6ba532"
PKG_SHA256="2497559cfd7d7c34fe2bf68f15028e5c3f6226b2a1724f50dfe5c2a9a18768c0"
PKG_SOURCE_NAME="${PKG_NAME}-aarch64-${PKG_VERSION}.tar.xz"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"
PKG_DEPENDS_TARGET="toolchain bl30"
PKG_LONGDESC="Tool to inject bootloader blob BL30.bin on internal eMMC"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
  mkdir -p ${INSTALL}/usr/lib/coreelec
  mkdir -p ${INSTALL}/etc/inject_bl301
    install -m 0755 inject_bl301 ${INSTALL}/usr/sbin/inject_bl301
    install -m 0755 ${PKG_DIR}/scripts/check-bl301.sh ${INSTALL}/usr/lib/coreelec/check-bl301
    install -m 0755 ${PKG_DIR}/scripts/update-bl301.sh ${INSTALL}/usr/lib/coreelec/update-bl301
    install -m 0644 ${PKG_DIR}/config/bl301.conf ${INSTALL}/etc/inject_bl301/bl301.conf
}

post_install() {
  enable_service update-bl301.service
}
