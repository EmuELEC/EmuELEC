# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8822CS-aml"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/RTL8822CS-aml"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8822CS Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

case "${LINUX}" in
  amlogic-4.9)
    PKG_VERSION="4e31d08990bc2a84c937bf17d5be4b899ceb70ed"
    PKG_SHA256="6df2e60689830f454111e2cd2c2873c05c9ac8e0f39e8eb1934dbcac62263900"
    ;;
  amlogic-5.4)
    PKG_VERSION="4a06b4470a91c3f142b50fb7b8643fdcaa4cc2fc"
    PKG_SHA256="12fa600f9497d800a7b280435561ad4848e360cc6de491a48ae5a537cf554899"
    ;;
esac

PKG_URL="https://github.com/CoreELEC/RTL8822CS-aml/archive/${PKG_VERSION}.tar.gz"

post_unpack() {
  sed -i 's/-DCONFIG_CONCURRENT_MODE//g; s/^CONFIG_POWER_SAVING.*$/CONFIG_POWER_SAVING = n/g; s/^CONFIG_RTW_DEBUG.*/CONFIG_RTW_DEBUG = n/g' ${PKG_BUILD}/rtl88x2CS/Makefile
  sed -i 's/^#define CONFIG_DEBUG.*//g' ${PKG_BUILD}/rtl88x2CS/include/autoconf.h
  sed -i 's/#define DEFAULT_RANDOM_MACADDR.*1/#define DEFAULT_RANDOM_MACADDR 0/g' ${PKG_BUILD}/rtl88x2CS/core/rtw_ieee80211.c
  sed -i 's/rtw_drv_log_level/0/g' ${PKG_BUILD}/rtl88x2CS/core/*.c
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/rtl88x2CS \
    KSRC=$(kernel_path) \
    USER_EXTRA_CFLAGS="-fgnu89-inline"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
