# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="u-boot-script"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_DEPENDS_TARGET="u-boot-tools"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Compile scripts for u-boot environment."

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"
[ -n "$DEVICE" ] && PKG_NEED_UNPACK+=" $PROJECT_DIR/$PROJECT/devices/$DEVICE/bootloader"

make_target() {
  if find_dir_path bootloader/scripts ; then
    for src in $FOUND_PATH/*.src ; do
      mkimage -A $TARGET_KERNEL_ARCH -O linux -T script -C none -d "$src" "$(basename $src .src)"
    done
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader
    cp -a $PKG_BUILD/* $INSTALL/usr/share/bootloader/
}
