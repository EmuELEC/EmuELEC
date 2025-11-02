# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="obu_util"
PKG_VERSION="0.1"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://aomedia.googlesource.com/aom/+/refs/tags/v3.3.0/av1/common/obu_util.c"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="av1 obu_util"
PKG_TOOLCHAIN="manual"

make_target() {
  ${CC} *.c -c -I. ${CFLAGS}
  ${AR} -rcs libobu_util.a *.o
  ${RANLIB}  libobu_util.a
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/{lib,include}
  cp libobu_util.a ${SYSROOT_PREFIX}/usr/lib
  cp obu_util.h aom_codec.h aom_image.h aom_integer.h ${SYSROOT_PREFIX}/usr/include
}
