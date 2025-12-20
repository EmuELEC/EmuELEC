# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mt7603u-aml"
PKG_VERSION="0c53dfb"
PKG_SHA256="9e3eab02f3c3dd7de373c5d631c2069771e6ad783ecda36a484030ab4ec0ccec"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/khadas/android_hardware_wifi_mtk_drivers_mt7603"
PKG_URL="https://github.com/khadas/android_hardware_wifi_mtk_drivers_mt7603/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="mt7603u Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make LINUX_SRC=$(kernel_path) \
    ARCH=$TARGET_KERNEL_ARCH \
    CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    RT28xx_DIR=$PKG_BUILD \
    -f $PKG_BUILD/Makefile
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;

  mkdir -p $INSTALL/$(get_full_firmware_dir)
    cp $PKG_BUILD/conf/MT7603USTA.dat $INSTALL/$(get_full_firmware_dir)
}
