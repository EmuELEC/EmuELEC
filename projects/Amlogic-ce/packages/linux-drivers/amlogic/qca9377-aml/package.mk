# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qca9377-aml"
PKG_VERSION="311e24939b53d0cbaf303cde3ed1dc22349602a9"
PKG_SHA256="238e0174ec5ca3f87c184fade5eb7d1e4522d6af279aac6bd87f8bab24fc13ad"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://boundarydevices.com/new-silex-wifi-802-11ac-bt4-1-module/"
PKG_URL="https://github.com/boundarydevices/qcacld-2.0/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="qca9377 Linux Driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

PKG_PATCH_DIRS="$LINUX"

post_unpack() {
  sed -i 's,-Wall,,g; s,-Werror,,g' ${PKG_BUILD}/Kbuild
  sed -i 's,CDEFINES :=,CDEFINES := -Wno-misleading-indentation -Wno-unused-variable -Wno-unused-function,g' ${PKG_BUILD}/Kbuild
}

pre_make_target() {
  unset LDFLAGS
  unset CFLAGS
}

make_target() {
  make KERNEL_SRC="$(kernel_path)" \
    ARCH=${TARGET_KERNEL_ARCH} \
    CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
    CONFIG_BUILDROOT=y
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${PKG_BUILD}/wlan.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/wlan-${PKG_NAME}.ko
}
