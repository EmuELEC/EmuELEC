# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="w2-aml"
PKG_VERSION="caabab742672bf9b9744cc7502958a981656a521"
PKG_SHA256=""
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/w2-aml"
PKG_URL="https://github.com/CoreELEC/w2-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Amlogic W2 Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/aml_drv \
    CONFIG_ANDROID_GKI=y
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/aml
    find ${PKG_BUILD}/aml_drv/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/aml \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aml
    cp ${PKG_BUILD}/common/aml_w2_*.txt ${INSTALL}/$(get_full_firmware_dir)/aml
    cp ${PKG_BUILD}/common/wifi_w2_fw_sdio.bin ${INSTALL}/$(get_full_firmware_dir)/aml
    cp ${PKG_BUILD}/common/wifi_w2_fw_usb.bin ${INSTALL}/$(get_full_firmware_dir)/aml
}
