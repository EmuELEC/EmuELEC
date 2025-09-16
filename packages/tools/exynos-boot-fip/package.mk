# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="exynos-boot-fip"
PKG_LICENSE="nonfree"
PKG_VERSION="fb7ab5db7329705b2fe1398842d715d1bbeb33d2"
PKG_SHA256="271bb3ff90b6e995a55252bfb8de46405cdbd7f506eca2c3e673f911cdb876c1"
PKG_SITE="https://github.com/chewitt/exynos-boot-fip"
PKG_URL="https://github.com/chewitt/exynos-boot-fip/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Firmware Image Package (FIP) sources used with Exynos u-boot binaries in LibreELEC images"
PKG_TOOLCHAIN="manual"
PKG_STAMP="${UBOOT_SYSTEM}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/boot
    cp -P ${PKG_BUILD}/bl1.bin.hardkernel ${INSTALL}/usr/boot
    cp -P ${PKG_BUILD}/bl2.bin.hardkernel.720k_uboot ${INSTALL}/usr/boot
    cp -P ${PKG_BUILD}/tzsw.bin.hardkernel ${INSTALL}/usr/boot
}
