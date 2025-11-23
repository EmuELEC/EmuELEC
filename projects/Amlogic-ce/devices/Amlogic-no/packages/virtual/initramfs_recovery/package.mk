# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

. $(get_pkg_directory initramfs)/package.mk

PKG_NAME="initramfs_recovery"
PKG_DEPENDS_INIT="libc:init busybox:init u-boot-tools:init"
PKG_DEPENDS_TARGET="toolchain ${PKG_NAME}:init"

for i in ${PKG_DEPENDS_INIT}; do
  PKG_NEED_UNPACK+=" $(get_pkg_directory ${i})"
done

post_install() {
  cd ${BUILD}/${PKG_NAME}

  ln -sfn /usr/lib  ${BUILD}/${PKG_NAME}/lib
  ln -sfn /usr/bin  ${BUILD}/${PKG_NAME}/bin
  ln -sfn /usr/sbin ${BUILD}/${PKG_NAME}/sbin

  mkdir -p ${BUILD}/image
    find . | cpio -H newc -ov -R 0:0 > ${BUILD}/image/${PKG_NAME}.cpio
}
