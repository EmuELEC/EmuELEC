# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="EA6X21QX"
PKG_VERSION="212011848494533c59978be0e64a7b9c76209f29"
PKG_SHA256=""
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/daeiron/ea6x21qx_driver"
PKG_URL="https://github.com/daeiron/ea6x21qx_driver/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Seekwave EA6X21QX Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
	# create version file or build can fail sometimes
	perl -s ${PKG_BUILD}/drivers/skwifi/genver.pl \
	        ${PKG_BUILD}/drivers/skwifi/version.h

  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KERNEL_SRC=$(kernel_path)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/skw
    cp ${PKG_BUILD}/firmware/*.bin ${INSTALL}/$(get_full_firmware_dir)/skw
}
