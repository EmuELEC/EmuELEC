# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qca-firmware-aml"
PKG_VERSION="56716df3468fd87ade0ac98af5ec687376e9b4ef"
PKG_SHA256="4f3dd7ad50695c3f8205e38a1a703801d6033fcfda969c55606589229738178e"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3c"
PKG_SITE="https://github.com/CoreELEC/qca-firmware-aml"
PKG_URL="https://github.com/CoreELEC/qca-firmware-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="qca Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
    cp -a * ${INSTALL}/$(get_full_firmware_dir)

  # create a default firmware.conf for loading bluetooth NVM binaries
  # Possible parameter:
  # DEEP_SLEEP: Disable = 0 / Enable = 1
  # PCM: Master = 0 / Slave = 1
  mkdir -p ${INSTALL}/etc/bluetooth
    echo "DEEP_SLEEP=0
" > ${INSTALL}/etc/bluetooth/firmware.conf
}
