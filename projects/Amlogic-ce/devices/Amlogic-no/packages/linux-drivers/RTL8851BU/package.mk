# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8851BU"
PKG_VERSION="f94ea820634d3bd050009e861952d3b8eeef869a"
PKG_SHA256="43393114cc428e0b9b64eb87e88037a926daed1e6f6af92f7ad945138b9f4d5a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/neatojones/RTL8851bu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8851BU Linux driver"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       CONFIG_RTW_DEBUG=n
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp *.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
