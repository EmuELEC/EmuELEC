# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8852BS-aml"
PKG_VERSION="dd202f37cbffb0e93ba15746d373a87228334e5f"
PKG_SHA256="0acc9c0eb4203e690b4254cd563526b7aabfc7d43ec85dc7f2f5ef54212e0b41"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Stane1983/rtl8852bs-aml"
PKG_URL="https://github.com/Stane1983/rtl8852bs-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8852BS Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

post_unpack() {
  sed -i 's/#define DEFAULT_RANDOM_MACADDR.*/#define DEFAULT_RANDOM_MACADDR 0/g' ${PKG_BUILD}/core/rtw_ieee80211.c
}

make_target() {
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KSRC=$(kernel_path) \
    CONFIG_POWER_SAVE=n \
    CONFIG_RTW_DEBUG=n \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
