# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mali-midgard"
PKG_VERSION="2c2accf67356463ee661627b8705429256011dcb" # TX011-SW-99002-r28p0-01rel0
PKG_SHA256="506ec1e388f491f53a9acf8ca2077bd135a6d31f688ed7139ed0cd77f5c44d72"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://developer.arm.com/products/software/mali-drivers/"
PKG_URL="https://github.com/LibreELEC/mali-midgard/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="mali-midgard: Linux drivers for Mali Midgard GPUs"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

case ${PROJECT} in
  Allwinner)
    PKG_CONFIGS="CONFIG_MALI_PLATFORM_NAME=sunxi"
    ;;
  Amlogic)
    PKG_CONFIGS="CONFIG_MALI_PLATFORM_NAME=meson"
    ;;
  Rockchip)
    PKG_CONFIGS="CONFIG_MALI_PLATFORM_NAME=rk"
    ;;
esac

post_patch() {
  # rename kernel module to not clash with mali-bifrost
  find ${PKG_BUILD} -name Kbuild -exec sed -i 's/mali_kbase.o/mali_midgard.o/g; s/mali_kbase-/mali_midgard-/g' {} \;
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/driver/product/kernel/drivers/gpu/arm/midgard \
    EXTRA_CFLAGS="${PKG_EXTRA_CFLAGS}" \
    CONFIG_MALI_MIDGARD=m ${PKG_CONFIGS}
}

makeinstall_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/driver/product/kernel/drivers/gpu/arm/midgard \
    INSTALL_MOD_PATH=${INSTALL}/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
    modules_install
}
