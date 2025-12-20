# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qca6174-aml"
PKG_VERSION="c39cce4160817b0445afd4304b5b4dd2dcd29167"
PKG_SHA256="450df8193205b13e81342d90a7cfd6ee2842453b800b1080bfa8b365af2ba5b8"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/qca6174-aml"
PKG_URL="https://github.com/CoreELEC/qca6174-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="qca6174 Linux Driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

PKG_PATCH_DIRS="$LINUX"

post_unpack() {
  sed -i 's,-Wall,,g; s,-Werror,,g' ${PKG_BUILD}/AIO/drivers/qcacld-new/Kbuild
  sed -i 's,CDEFINES :=,CDEFINES := -Wno-misleading-indentation -Wno-unused-variable -Wno-unused-function,g' ${PKG_BUILD}/AIO/drivers/qcacld-new/Kbuild
}

pre_make_target() {
  unset LDFLAGS
  unset CFLAGS
}

make_target() {
  cd AIO/build
  make KERNELPATH="$(kernel_path)" \
    ARCH=${TARGET_KERNEL_ARCH} \
    CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
    INSTALL_ROOT=${PKG_BUILD} \
    CONFIG_BUILDROOT=y
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${PKG_BUILD}/lib/modules/wlan.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/wlan-${PKG_NAME}.ko
}
