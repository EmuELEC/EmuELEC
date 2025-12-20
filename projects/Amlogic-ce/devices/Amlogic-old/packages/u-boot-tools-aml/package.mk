# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="u-boot-tools-aml"
PKG_VERSION="2016.03"
PKG_SHA256="e49337262ecac44dbdeac140f2c6ebd1eba345e0162b0464172e7f05583ed7bb"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="ftp://ftp.denx.de/pub/u-boot/u-boot-$PKG_VERSION.tar.bz2"
PKG_DEPENDS_HOST="gcc:host"
PKG_DEPENDS_TARGET="toolchain u-boot-tools-aml:host"
PKG_LICENSE="GPL"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."

make_host() {
  make mrproper
  make dummy_defconfig
  make tools-only
}

make_target() {
  CROSS_COMPILE="$TARGET_PREFIX" LDFLAGS="" ARCH=arm make dummy_defconfig
  CROSS_COMPILE="$TARGET_PREFIX" LDFLAGS="" ARCH=arm make env
}

makeinstall_host() {
  mkdir -p $TOOLCHAIN/bin
    cp tools/mkimage $TOOLCHAIN/bin
}

makeinstall_target() {
  mkdir -p $INSTALL/etc
    cp $PKG_DIR/config/fw_env.config $INSTALL/etc/fw_env.config

  mkdir -p $INSTALL/usr/sbin
    cp tools/env/fw_printenv $INSTALL/usr/sbin/fw_printenv
    cp tools/env/fw_printenv $INSTALL/usr/sbin/fw_setenv
}
