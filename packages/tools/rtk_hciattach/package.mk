# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtk_hciattach"
PKG_VERSION="3d0ed39cfdd24343715057e93134cd63b7321827"
PKG_SHA256="6c5908e4e07fe4a74c54f5b58f01bdbeffc2aa2f8b529c5f32ce897e087edf7a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Caesar-github/rkwifibt"
PKG_URL="https://github.com/Caesar-github/rkwifibt/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_IS_KERNEL_PKG="yes"
PKG_LONGDESC="Realtek BT firmware loader and HCI UART driver"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=2 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz \
      -C ${PKG_BUILD} rkwifibt-${PKG_VERSION}/realtek
}

make_target() {
  # Build rtk_hciattach userspace tool
  make -C ${PKG_BUILD}/rtk_hciattach/ CC=${CC}

  # Build hci_uart.ko kernel module (Realtek H5 support)
  make -C $(kernel_path) M=${PKG_BUILD}/bluetooth_uart_driver \
    ARCH=${TARGET_KERNEL_ARCH} \
    CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
    modules
}

makeinstall_target() {
  # Install rtk_hciattach binary
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/rtk_hciattach/rtk_hciattach ${INSTALL}/usr/bin/
  chmod 755 ${INSTALL}/usr/bin/rtk_hciattach

  # Install hci_uart.ko module
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/bluetooth_uart_driver/hci_uart.ko \
     ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/

  # Create firmware symlinks for rtk_hciattach
  # rtk_hciattach looks in /usr/lib/firmware/rtlbt/ for firmware
  # Kernel firmware package installs to rtl_bt/ with .bin extension
  # rtk_hciattach identifies chip as RTL8822CS and looks for rtl8822cs_fw / rtl8822cs_config
  FIRMWARE_DIR="${INSTALL}/$(get_full_firmware_dir)/rtlbt"
  mkdir -p "${FIRMWARE_DIR}"
  ln -sf ../rtl_bt/rtl8822cs_fw.bin "${FIRMWARE_DIR}/rtl8822cs_fw"
  ln -sf ../rtl_bt/rtl8822cs_config.bin "${FIRMWARE_DIR}/rtl8822cs_config"
}
