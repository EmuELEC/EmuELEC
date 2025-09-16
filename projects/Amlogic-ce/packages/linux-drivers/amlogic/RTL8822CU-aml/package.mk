# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8822CU-aml"
PKG_VERSION="f1a4a3abb993245bf28bf1e2254f47f76972fd6d"
PKG_SHA256="2ad96072107478964b9308c19fa0edefdbb70e4c088256432b6fe5b903ebcf35"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/khadas/android_vendor_wifi_driver_realtek_8822cu/"
PKG_URL="https://github.com/khadas/android_vendor_wifi_driver_realtek_8822cu/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8822CU Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

post_unpack() {
  sed -i 's/-DCONFIG_CONCURRENT_MODE//g; s/^CONFIG_POWER_SAVING.*$/CONFIG_POWER_SAVING = n/g; s/^CONFIG_RTW_DEBUG.*/CONFIG_RTW_DEBUG = n/g' ${PKG_BUILD}/*/Makefile
  sed -i 's/^#define CONFIG_DEBUG.*//g' ${PKG_BUILD}/*/include/autoconf.h
  sed -i 's/#define DEFAULT_RANDOM_MACADDR.*1/#define DEFAULT_RANDOM_MACADDR 0/g' ${PKG_BUILD}/*/core/rtw_ieee80211.c
  sed -i 's/rtw_drv_log_level/0/g' ${PKG_BUILD}/*/core/*.c
}

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make -C $(kernel_path) M=${PKG_BUILD}/rtl88x2CU \
    ARCH=${TARGET_KERNEL_ARCH} \
    KSRC=$(kernel_path) \
    CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
    USER_EXTRA_CFLAGS="-fgnu89-inline"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
