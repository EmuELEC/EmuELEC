# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ssv6xxx-aml-3.14"
PKG_VERSION="1041e7d"
PKG_SHA256="1d96db8eec06c8a2c43f2c8024cc573e2bbce08fb0504fd9b6671224335e7d5f"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://libreelec.tv"
PKG_URL="https://sources.libreelec.tv/devel/ssv6xxx-aml-1041e7d.tar.xz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="ssv6xxx Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  sed -i 's,hw_cap_p2p = on,hw_cap_p2p = off,g' firmware/ssv6051-wifi.cfg
}

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  if [ "$TARGET_KERNEL_ARCH" = "arm64" ]; then
    PLATFORM="aml-s905"
  else
    PLATFORM="aml-s805"
  fi

  cd $PKG_BUILD
    ./ver_info.pl include/ssv_version.h
    cp Makefile.android Makefile
    sed -i 's,PLATFORMS =,PLATFORMS = '"$PLATFORM"',g' Makefile
    make module SSV_ARCH="$TARGET_KERNEL_ARCH" \
      SSV_CROSS="$TARGET_KERNEL_PREFIX" \
      SSV_KERNEL_PATH="$(kernel_path)"
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;

  mkdir -p $INSTALL/$(get_full_firmware_dir)/ssv6051
    cp $PKG_BUILD/firmware/* $INSTALL/$(get_full_firmware_dir)/ssv6051
}
