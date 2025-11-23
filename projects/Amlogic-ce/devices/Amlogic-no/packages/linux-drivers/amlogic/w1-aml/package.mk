# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="w1-aml"
PKG_VERSION="1a979d834799ffdd9f67a3856171b19f0b9fd3e3"
PKG_SHA256=""
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
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/project_w1/vmac
}

pre_make_target() {

  find ${PKG_BUILD} -name "*.cmd" -delete 2>/dev/null || true
  find ${PKG_BUILD} -name ".*.cmd" -delete 2>/dev/null || true
}


makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/aml
    find ${PKG_BUILD}/project_w1/vmac/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/aml \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aml
    cp ${PKG_BUILD}/project_w1/vmac/aml_wifi*.txt ${INSTALL}/$(get_full_firmware_dir)/aml
}
