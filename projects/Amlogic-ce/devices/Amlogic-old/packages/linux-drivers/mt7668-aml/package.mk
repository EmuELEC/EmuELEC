# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.tv)

PKG_NAME="mt7668-aml"
PKG_VERSION="fd76e10404b220c552fc7951f5a359b56d599e3b"
PKG_SHA256="1fb62a608b9ce8ba8157a8025ba0d76ad1d085510b27982e4af33575d2841308"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/khadas/android_hardware_wifi_mtk_drivers_mt7668"
PKG_URL="https://github.com/khadas/android_hardware_wifi_mtk_drivers_mt7668/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="mt7668 Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make EXTRA_CFLAGS="-w" \
    KERNELDIR=$(kernel_path) \
    ARCH=$TARGET_KERNEL_ARCH \
    CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    -f $PKG_BUILD/Makefile
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;

  mkdir -p $INSTALL/$(get_full_firmware_dir)
    cp $PKG_BUILD/7668_firmware/* $INSTALL/$(get_full_firmware_dir)
}
