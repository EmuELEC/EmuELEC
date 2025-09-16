# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="smartchip"
PKG_VERSION="5d41ac040ecd2072498da88100305c1b444c12c7"
PKG_SHA256="89fde1c8d4850f72e821f044ff7050e4a0093b94a207b6478d31a5eaae40fddc"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/smartchip"
PKG_URL="https://github.com/CoreELEC/smartchip/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="SmartChip Integrated Circuits"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  for module in s9083 s9188 richv300; do
    echo
    echo "making ${module}..."
    kernel_make -C ${PKG_BUILD}/trunk_driver \
      KSRC=$(kernel_path) \
      CONFIG_DRIVER_VER="${PKG_VERSION}" \
      CONFIG_DBG_COLOR=n \
      CONFIG_HIF_PORT=sdio \
      CONFIG_CHIP=${module} \
      HOST_PLAT=amlogic905W2

    mv ${PKG_BUILD}/trunk_driver/*.ko ${PKG_BUILD}

    kernel_make -C ${PKG_BUILD}/trunk_driver \
      KSRC=$(kernel_path) \
      clean
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/smartchip
    cp -r ${PKG_BUILD}/trunk_driver/fw/*.bin ${INSTALL}/$(get_full_firmware_dir)
    cp -r ${PKG_BUILD}/trunk_driver/wifi.cfg ${INSTALL}/$(get_full_firmware_dir)/smartchip
}
