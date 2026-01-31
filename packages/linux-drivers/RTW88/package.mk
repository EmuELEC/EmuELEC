# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="RTW88"
PKG_VERSION="2dd31d9b6a21ec1fba5cc7a67ae3e4a450eba9ad"
PKG_SHA256=""  # Will be filled after first build
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtw88"
PKG_URL="https://github.com/lwfinger/rtw88/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTW88 WiFi 5 Linux drivers - supports RTL8822CS, RTL8822BS, RTL8821CS, RTL8723DS, RTL8723CS and more"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

# Supported chipsets:
# PCIe: RTL8723DE, RTL8812AE, RTL8814AE, RTL8821AE, RTL8821CE, RTL8822BE, RTL8822CE
# SDIO: RTL8723CS, RTL8723DS, RTL8821CS, RTL8822BS, RTL8822CS
# USB:  RTL8723DU, RTL8811AU, RTL8811CU, RTL8812AU, RTL8812BU, RTL8812CU
# USB:  RTL8814AU, RTL8821AU, RTL8821CU, RTL8822BU, RTL8822CU

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  # Install firmware
  mkdir -p ${INSTALL}/usr/lib/firmware/rtw88
    cp -r ${PKG_BUILD}/firmware/* ${INSTALL}/usr/lib/firmware/rtw88/ 2>/dev/null || true
}
