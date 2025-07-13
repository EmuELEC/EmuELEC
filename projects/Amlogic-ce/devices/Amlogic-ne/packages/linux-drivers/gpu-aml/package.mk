# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gpu-aml"
PKG_VERSION="1e963e9e181df78a6fb318010b0553084ed1523d"
PKG_SHA256="968703f7845be782fb410bbf8f616919e2eb775b32be7669ae60f4ee790feb5c"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/gpu-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="gpu-aml: Linux drivers for Mali GPUs found in Amlogic Meson SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/bifrost/r25p0/kernel/drivers/gpu/arm \
    CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME="devicetree" \
    EXTRA_CFLAGS="-I${PKG_BUILD}/dvalin/kernel/include -DCONFIG_MALI_LOW_MEM=0"
}

makeinstall_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/bifrost/r25p0/kernel/drivers/gpu/arm \
    INSTALL_MOD_PATH=${INSTALL}/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
  modules_install
}
