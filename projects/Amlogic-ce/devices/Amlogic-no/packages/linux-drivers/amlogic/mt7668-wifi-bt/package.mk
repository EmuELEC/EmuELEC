# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Team CoreELEC (https://coreelec.org)

PKG_NAME="mt7668-wifi-bt"
PKG_VERSION="54816a09cee5f74c62ba1b53024787cd3cf3e2e8"
PKG_SHA256="2560fac936642fa2a830c584b151d3e20d18ee6d0c195ac8109ea79a962caf81"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/noob404yt/mt7668-wifi-bt"
PKG_URL="https://github.com/CoreELEC/MT7668/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="WiFi & Bluetooth Drivers for MT7668"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  cd ${PKG_BUILD}/MT7668-Bluetooth
  kernel_make EXTRA_CFLAGS="-w" \
    KCFLAGS="-Wno-int-conversion" \
    KERNEL_SRC=$(kernel_path)

  echo

  cd ${PKG_BUILD}/MT7668-WiFi
  kernel_make EXTRA_CFLAGS="-w" \
    KCFLAGS="-Wno-incompatible-function-pointer-types" \
    KERNELDIR=$(kernel_path)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
  cp ${PKG_BUILD}/MT7668-WiFi/7668_firmware/* ${INSTALL}/$(get_full_firmware_dir)
}
