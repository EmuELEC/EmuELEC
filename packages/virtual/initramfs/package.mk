# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="initramfs"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="http://www.openelec.tv"
PKG_URL=""
PKG_DEPENDS_INIT="libc:init busybox:init splash-image:init util-linux:init e2fsprogs:init dosfstools:init terminus-font:init bkeymaps:init fakeroot:host"
PKG_DEPENDS_TARGET="toolchain initramfs:init"
PKG_SECTION="virtual"
PKG_LONGDESC="Metapackage for installing initramfs"

if [ "${ISCSI_SUPPORT}" = yes ]; then
  PKG_DEPENDS_INIT+=" open-iscsi:init"
fi

if [ "${INITRAMFS_PARTED_SUPPORT}" = yes ]; then
  PKG_DEPENDS_INIT+=" parted:init"
fi

for i in ${PKG_DEPENDS_INIT}; do
  PKG_NEED_UNPACK+=" $(get_pkg_directory ${i})"
done

post_install() {
  if [ "$BUILD_ANDROID_BOOTIMG" = "yes" ]; then
  ( 
    cd $BUILD/initramfs

    ln -sfn /usr/lib  $BUILD/initramfs/lib
    ln -sfn /usr/bin  $BUILD/initramfs/bin
    ln -sfn /usr/sbin $BUILD/initramfs/sbin

    mkdir -p $BUILD/image
    fakeroot -- sh -c \
      "mkdir -p dev; mknod -m 600 dev/console c 5 1; find . | cpio -H newc -ov -R 0:0 > $BUILD/image/initramfs.cpio"
  )
  fi
} 
