# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mali-bifrost"
PKG_VERSION="af7c8d8bcdedd792a8d101d3a11876bb8bcbe3da" # BX301A01B-SW-99002-r16p0-01rel0
PKG_SHA256="712ba83f28bf687e2147f0f586678421b0d2cb5620423e93e7b7c9ddf35c1da5"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://developer.arm.com/products/software/mali-drivers/bifrost-kernel"
PKG_URL="https://github.com/LibreELEC/mali-bifrost/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="mali-bifrost: the Linux kernel driver for ARM Mali Bifrost GPUs"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

case ${PROJECT} in
  Amlogic)
    PKG_MALI_PLATFORM_CONFIG="config.meson-g12a"
    ;;
esac

make_target() {
  kernel_make KDIR=$(kernel_path) -C ${PKG_BUILD} \
       CONFIG_NAME=${PKG_MALI_PLATFORM_CONFIG}
}

makeinstall_target() {
  DRIVER_DIR=${PKG_BUILD}/driver/product/kernel/drivers/gpu/arm/midgard/

  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${DRIVER_DIR}/mali_kbase.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/
}
