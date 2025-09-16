# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8821CU"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/smp79/rtl8821CU"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_SECTION="driver"
PKG_LONGDESC="Realtek RTL8821CU Linux driver"
PKG_IS_KERNEL_PKG="yes"

case "$LINUX" in
  amlogic-3.14)
    PKG_VERSION="178fcbf4f1bf5b94580b5708016d0b2c2ded1720"
    PKG_SHA256="29d3e053dd1fad37ee03de65e4ed2b25a4fb9aaf8bb6bd435da477753d03ad26"
    PKG_URL="https://github.com/smp79/rtl8821CU/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_DIR="rtl8821CU-$PKG_VERSION*"
    ;;
  amlogic-4.9|odroid-go-a-4.4)
    PKG_VERSION="f7910283478ac1b508ff163d30e4b374bf99f7cb"
    PKG_SHA256="b2128cbc23ecf9b17bbbd9652a2453d73403276a56b11eb8a795d168156cd53e"
    PKG_URL="https://github.com/smp79/rtl8821CU/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_DIR="rtl8821CU-$PKG_VERSION*"
    ;;
esac

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make \
       ARCH=$TARGET_KERNEL_ARCH \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
       CONFIG_POWER_SAVING=n
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    cp *.ko $INSTALL/$(get_full_module_dir)/$PKG_NAME
}
