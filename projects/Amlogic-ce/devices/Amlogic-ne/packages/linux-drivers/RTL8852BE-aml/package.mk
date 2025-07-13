# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8852BE-aml"
PKG_VERSION="5da5adca92ac38a6c3a782147d45e48da577dce3"
PKG_SHA256="c256cac841bdf541959ae8f483c99efb0b8ac944e254e9dd60402ad1aaf647f5"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/RTL8852BE-aml"
PKG_URL="https://github.com/CoreELEC/RTL8852BE-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8852BE-aml Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C ${PKG_BUILD}/rtl8852BE \
    M=${PKG_BUILD}/rtl8852BE \
    KSRC=$(kernel_path) \
    OUT_DIR= \
    CONFIG_RTKM=m \
    CONFIG_SDIO_HCI=n \
    CONFIG_PCI_HCI=y \
    CONFIG_POWER_SAVE=n \
    CONFIG_RTW_DEBUG=n \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
