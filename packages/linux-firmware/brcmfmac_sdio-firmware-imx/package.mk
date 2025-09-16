# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="brcmfmac_sdio-firmware-imx"
PKG_VERSION="0.1"
PKG_SHA256="4c8ed8ae39ecd05d7e3aeebc98cf230912cdcc887fa78d5112f981b6f9358b6e"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/LibreELEC/LibreELEC.tv"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Firmware for brcm bluetooth chips used in some Freescale iMX based devices."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -av brcm_patchram_plus ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/
    cp -av firmware/brcm ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/
}
