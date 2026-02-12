# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="RTL8822CS"
PKG_VERSION="main"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/friendlyarm/rtl8822cs"
PKG_URL="https://github.com/friendlyarm/rtl8822cs/archive/refs/heads/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8822CS SDIO WiFi driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  export KCFLAGS+=" -Wno-array-bounds -Wno-stringop-overflow -Wno-restrict -Wno-address -Wno-stringop-overread"
  make V=1 \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       CONFIG_POWER_SAVING=n
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/
}
