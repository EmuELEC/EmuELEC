# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="arm-mem"
PKG_VERSION="b48ea154fd74410022d8189003cd69fad8f3d02c" # Apr 30, 2019
PKG_SHA256="93240defef3abba7d42a7420e55ae4f8b90cc99ef16044fdfb8b5820a17e766d"
PKG_ARCH="arm"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/bavison/arm-mem"
PKG_URL="https://github.com/bavison/arm-mem/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_INIT="toolchain arm-mem"
PKG_LONGDESC="arm-mem is a ARM-accelerated versions of selected functions from string.h"
PKG_BUILD_FLAGS="+pic"

if target_has_feature neon; then
  PKG_LIB_ARM_MEM="libarmmem-v7l.so"
else
  PKG_LIB_ARM_MEM="libarmmem-v6l.so"
fi

PKG_MAKE_OPTS_TARGET="${PKG_LIB_ARM_MEM}"

pre_make_target() {
  export CROSS_COMPILE=${TARGET_PREFIX}
}

make_init() {
  : # reuse make_target()
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -P ${PKG_LIB_ARM_MEM} ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/etc
    echo "/usr/lib/${PKG_LIB_ARM_MEM}" >> ${INSTALL}/etc/ld.so.preload
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/lib
    cp -P ${PKG_LIB_ARM_MEM} ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/etc
    echo "/usr/lib/${PKG_LIB_ARM_MEM}" >> ${INSTALL}/etc/ld.so.preload
}
