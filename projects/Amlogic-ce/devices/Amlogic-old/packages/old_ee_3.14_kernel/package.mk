# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="old_ee_3.14_kernel"
PKG_VERSION="1"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Old alternative kernel for Amlogic-old"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  cp ${PKG_BUILD}/* ${INSTALL}/usr/share/bootloader
}
