# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="mt76"
PKG_VERSION="558ea6fb54b636998ea2fcfc8fcad75f0ddc218d"
PKG_SHA256="bfaaee047ccacf9639f66a9bd4dd837cbd31f1c8bcf78e784831625b16d39eb7"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/mt76"
PKG_URL="https://github.com/CoreELEC/mt76/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="MediaTek Linux v5.15 dev WiFi/BT drivers"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  cd ${PKG_BUILD}/bluetooth

  kernel_make \
    KCFLAGS="-DCONFIG_BT_MTK" \
    KERNEL_SRC=$(kernel_path)

  echo
  cd ${PKG_BUILD}/mt76

  kernel_make \
    CONFIG_MT76x0_COMMON=m \
    CONFIG_MT76x0U=m \
    CONFIG_MT76x2_COMMON=m \
    CONFIG_MT76x2U=m \
    CONFIG_MT7615_COMMON=m \
    CONFIG_MT7663_USB_SDIO_COMMON=m \
    CONFIG_MT7663S=m \
    CONFIG_MT7663U=m \
    CONFIG_MT7921_COMMON=m \
    CONFIG_MT7921S=m \
    KCFLAGS="-DCONFIG_MT76_LEDS" \
    KERNEL_SRC=$(kernel_path)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
