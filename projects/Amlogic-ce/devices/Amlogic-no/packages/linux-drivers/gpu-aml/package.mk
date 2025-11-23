# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gpu-aml"
PKG_VERSION="f11ecbdec0866ffd99efbcf7104ebdf84e5173f9"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/gpu-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="gpu-aml: Linux drivers for Mali GPUs found in Amlogic Meson SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  GPU_DRIVERS_ARCHITECTURE_REVISION="bifrost/r44p0:n valhall/r44p0:n:jm valhall/r44p0:y:csf"
}

make_target() {
  for driver_arch_rev in ${GPU_DRIVERS_ARCHITECTURE_REVISION}; do
    driver_version=$(echo "${driver_arch_rev}" | awk -F ":" '{ print $1 }')
    CONFIG_MALI_CSF_SUPPORT="CONFIG_MALI_CSF_SUPPORT=$(echo "${driver_arch_rev}" | awk -F ":" '{ print $2 }')"
    front_end=$(echo "${driver_arch_rev}" | awk -F ":" '{ print $3 }')
    architecture=$(echo "${driver_version}" | awk -F "/" '{ print $1 }')
    echo
    echo "building ${driver_version}"

    kernel_make -C ${PKG_BUILD}/${driver_version}/kernel/drivers/gpu/arm \
      KERNEL_SRC=$(kernel_path) \
      clean

    if [ -n "${front_end}" ]; then
      echo "replace compatible for correct GPU front end"
      sed -i "s|.compatible = \"arm,mali-${architecture}.*\"|.compatible = \"arm,mali-${architecture}-${front_end}\"|" \
        ${driver_version}/kernel/drivers/gpu/arm/midgard/mali_kbase_core_linux.c
    fi

    kernel_make -C ${PKG_BUILD}/${driver_version}/kernel/drivers/gpu/arm \
      KERNEL_SRC=$(kernel_path) \
      ${CONFIG_MALI_CSF_SUPPORT} \
      CONFIG_MALI_DEVFREQ=n \
      KCFLAGS=" -DCONFIG_MALI_LOW_MEM=0"

    kernel_make -C ${PKG_BUILD}/${driver_version}/kernel/drivers/gpu/arm \
      KERNEL_SRC=$(kernel_path) \
      INSTALL_MOD_PATH=${INSTALL}/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
      modules_install

    [ -n "${front_end}" ] && module_name="mali_kbase_${architecture}_${front_end}.ko" || module_name="mali_kbase_${architecture}.ko"
    mv ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/$(get_module_dir)/extra/midgard/mali_kbase.ko \
       ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/$(get_module_dir)/extra/midgard/${module_name}
  done
}
