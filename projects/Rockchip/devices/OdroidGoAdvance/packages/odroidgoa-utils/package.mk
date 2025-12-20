# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="odroidgoa-utils"
PKG_VERSION=""
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_DEPENDS_TARGET="toolchain python-evdev enable-oga-sleep usb-modeswitch light retrorun"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Support scripts for the ODROID-GO Advance"
PKG_TOOLCHAIN="manual"

if [ "${ARCH}" = "aarch64" ]; then
  PKG_DEPENDS_TARGET+=" lib32-retrorun"
fi

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cp * $INSTALL/usr/bin
}

post_install() {  
  enable_service odroidgoa-hotkeys.service
  enable_service odroidgoa-headphones.service
}
