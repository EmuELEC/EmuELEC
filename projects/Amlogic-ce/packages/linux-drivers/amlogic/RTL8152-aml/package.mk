# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8152-aml"
PKG_VERSION="cee2df544a6013a8efe4ed1493f594ca50b8d3c8"
PKG_SHA256="fadfebca469e2203e5aee1c727a7e3916f85a3a5f499c08fce0138bc67c1c92e"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/bb-qq/r8152"
PKG_URL="https://github.com/bb-qq/r8152/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="Realtek RTL8152/RTL8153/RTL8156 Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  LDFLAGS="" make -C $(kernel_path) M=$PKG_BUILD \
    ARCH=$TARGET_KERNEL_ARCH \
    KSRC=$(kernel_path) \
    CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    USER_EXTRA_CFLAGS="-fgnu89-inline"
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;
}
