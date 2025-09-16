# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8723DS-aml"
PKG_VERSION="75b11e99be6cc02cea6a00310633b191de962098"
PKG_SHA256="93324f12e415e13f7b4c9359dcf8231fb4a4a7b459a01504828bfe1ee220502a"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtl8723ds"
PKG_URL="https://github.com/lwfinger/rtl8723ds/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8723DS Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

post_unpack() {
  sed -i 's/#define DEFAULT_RANDOM_MACADDR.*/#define DEFAULT_RANDOM_MACADDR 0/g' ${PKG_BUILD}/core/rtw_ieee80211.c
}

make_target() {
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KSRC=$(kernel_path) \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
