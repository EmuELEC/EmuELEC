# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gpu-aml"
PKG_VERSION="ecf394cb42126b08da5b2abbbc3e07ae10850024"
PKG_SHA256="86715698649650478f107210f285d4308ce28c472102c9322f580ef7a5051f27"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/gpu-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="gpu-aml: Linux drivers for Mali GPUs found in Amlogic Meson SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  GPU_DRIVERS_ARCHITECTURE_REVISION="bifrost/r37p0 valhall/r41p0"
}

make_target() {
  for driver_arch_rev in ${GPU_DRIVERS_ARCHITECTURE_REVISION}; do
    echo
    echo "building ${driver_arch_rev}"

    kernel_make -C $(kernel_path) M=${PKG_BUILD}/${driver_arch_rev}/kernel/drivers/gpu/arm \
      CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME="devicetree" \
      EXTRA_CFLAGS="-I${PKG_BUILD}/${driver_arch_rev}/kernel/include -DCONFIG_MALI_LOW_MEM=0"
  done
}

makeinstall_target() {
  for driver_arch_rev in ${GPU_DRIVERS_ARCHITECTURE_REVISION}; do
    echo
    echo "modules install ${driver_arch_rev}"

    driver_arch=${driver_arch_rev%%/*}

    kernel_make -C $(kernel_path) M=${PKG_BUILD}/${driver_arch_rev}/kernel/drivers/gpu/arm \
      INSTALL_MOD_PATH=${INSTALL}/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
      modules_install

    mv ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/$(get_module_dir)/extra/midgard/mali_kbase.ko \
       ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/$(get_module_dir)/extra/midgard/mali_kbase_${driver_arch}.ko
  done
}
