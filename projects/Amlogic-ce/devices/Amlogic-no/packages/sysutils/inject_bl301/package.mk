# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="inject_bl301"
PKG_VERSION="fdd519917b8c257ea56cced7e962a2a89f60fb37"
PKG_SOURCE_NAME="${PKG_NAME}-${ARCH}-${PKG_VERSION}.tar.xz"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"
PKG_DEPENDS_TARGET="toolchain bl30"
PKG_LONGDESC="Tool to inject bootloader blob BL30.bin on internal eMMC"
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  arm)
    PKG_SHA256="5be388fd4728b5d44a9f68321aa840bba94b5e050d58a04b77320885f2851281"
    ;;
  aarch64)
    PKG_SHA256="04a38b47264cccf2dbdf8f9f1a9606740687d3e30d4d21a02b0845901dcde456"
    ;;
esac

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
