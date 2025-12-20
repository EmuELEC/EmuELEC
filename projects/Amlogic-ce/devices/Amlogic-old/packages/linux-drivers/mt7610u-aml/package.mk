# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.tv)

PKG_NAME="mt7610u-aml"
PKG_VERSION="c7a38f2bdde7a9e70f5d0753d4810f32dd1f6720"
PKG_SHA256="84bfa9aa8b56f7db4b43fac56a6b9e267bf8cb13f94aeff22d1aa38a7a965e86"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/osmc/mt7610u"
PKG_URL="https://github.com/osmc/mt7610u/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="mt7610u-$PKG_VERSION/mt7610u"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="mt7610u Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make LINUX_SRC=$(kernel_path) \
    ARCH=$TARGET_KERNEL_ARCH \
    CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    RT28xx_DIR=$PKG_BUILD \
    -f $PKG_BUILD/Makefile
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;
}
