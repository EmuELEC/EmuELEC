# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="ceemmc"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Tool to install CoreELEC on internal eMMC"
PKG_TOOLCHAIN="manual"
PKG_VERSION="d8058180fef88a8391f1f3410954922ee60bfa32"

case "${ARCH}" in
  arm)
    PKG_SHA256="3b773532f7cb6f2a0934c27da6ee14f57d0fd53da9772846243c708b5cdddcd4"
    ;;
  aarch64)
    PKG_SHA256="5d2826f77eda075d4a24d11dc64111378615aa15baf651638ac638031cebe0ae"
    ;;
esac

PKG_SOURCE_NAME="${PKG_NAME}-${ARCH}-${PKG_VERSION}.tar.xz"
PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
    install -m 0755 ceemmc ${INSTALL}/usr/sbin/ceemmc
}
