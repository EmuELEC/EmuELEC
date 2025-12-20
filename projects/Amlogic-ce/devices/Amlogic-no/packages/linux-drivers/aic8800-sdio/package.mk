# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Team CoreELEC (https://coreelec.org)

PKG_NAME="aic8800-sdio"
PKG_VERSION="bf2b14e8357f65e6fa84da2905ea5c0756c7791c"
PKG_SHA256="2623b85b977d7792d0bc765d4a47d32028bd328756bca2b3f75536366389be62"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="https://github.com/radxa-pkg/aic8800/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="AIC8800 SDIO WiFi and Bluetooth drivers"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C ${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800 \
    M=${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800 \
    PWD=${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800 \
    KDIR=$(kernel_path) \
    CONFIG_PLATFORM_AMLOGIC=y \
    CONFIG_PLATFORM_UBUNTU=n \
    CONFIG_AIC_FW_PATH=/lib/firmware/aic8800D80 \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800/*/*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aic8800D80
  cp ${PKG_BUILD}/src/SDIO/driver_fw/fw/aic8800/* ${INSTALL}/$(get_full_firmware_dir)/aic8800D80
}
