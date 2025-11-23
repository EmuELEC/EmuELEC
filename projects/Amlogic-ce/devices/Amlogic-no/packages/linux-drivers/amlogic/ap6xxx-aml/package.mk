# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="ap6xxx-aml"
PKG_VERSION="b2541e247f88e84873041cad9d2605aa4202d352"
PKG_SHA256=""
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_URL="https://github.com/CoreELEC/ap6xxx-aml/archive/${PKG_VERSION}.tar.gz"
PKG_SITE="https://github.com/CoreELEC/ap6xxx-aml"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="ap6xxx: Linux drivers for AP6xxx WLAN chips used in some devices based on Amlogic SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {

  find ${PKG_BUILD} -name "*.cmd" -delete 2>/dev/null || true
  find ${PKG_BUILD} -name ".*.cmd" -delete 2>/dev/null || true
}


make_target() {
  echo
  echo "building ap6275s and others"
  kernel_make -C  ${PKG_BUILD}/bcmdhd.101.10.591.x \
       M=${PKG_BUILD}/bcmdhd.101.10.591.x \
       PWD=${PKG_BUILD}/bcmdhd.101.10.591.x \
       KERNEL_SRC=$(kernel_path) \
       CONFIG_BCMDHD_DISABLE_WOWLAN=y \
       CONFIG_BCMDHD_SDIO=y \
       CONFIG_ANDROID_14=y \
       bcmdhd_sdio

  echo "building ap6275p"
  kernel_make -C  ${PKG_BUILD}/bcmdhd.101.10.591.x \
       M=${PKG_BUILD}/bcmdhd.101.10.591.x \
       PWD=${PKG_BUILD}/bcmdhd.101.10.591.x \
       KERNEL_SRC=$(kernel_path) \
       CONFIG_BCMDHD_DISABLE_WOWLAN=y \
       CONFIG_BCMDHD_PCIE=y \
       CONFIG_ANDROID_14=y \
       bcmdhd_pcie
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/*/*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
