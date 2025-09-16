# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8852BE-aml"
PKG_VERSION="b28630b2cd48748cb74d02cc3fce238ec6fef411"
PKG_SHA256="52c0e32e3917a3160e4c468a7bbe9fa21fd75c1ac0eb73883309e4e1cd11f61e"
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
