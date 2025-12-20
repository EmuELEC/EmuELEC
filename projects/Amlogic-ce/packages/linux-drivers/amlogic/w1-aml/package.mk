# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="w1-aml"
PKG_VERSION="87d7603a6ec06688a3bb6bc68d9daad300e32de3"
PKG_SHA256="a3f1aad71b82b3bf08ee4936dced1844bcb57fe0a814811754aa99981c44b3c6"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/w1-aml"
PKG_URL="https://github.com/CoreELEC/w1-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Amlogic W150S1 Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
if [ "${TARGET_ARCH}" = "arm" ]; then
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/project_w1/vmac
else
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/project_w1/vmac \
    subdir-ccflags-y="-mno-outline-atomics"
fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/project_w1/vmac/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/w1
    cp ${PKG_BUILD}/project_w1/vmac/aml_wifi*.txt ${INSTALL}/$(get_full_firmware_dir)/w1
}
