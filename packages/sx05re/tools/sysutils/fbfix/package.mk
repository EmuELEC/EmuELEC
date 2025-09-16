# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbfix"
PKG_VERSION="v1"
PKG_LICENSE="Public Domain"
PKG_SITE="https://forum.odroid.com/viewtopic.php?t=34827"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="A workaround used to fix framebuffer issues on s922x kernel v4.x"
PKG_TOOLCHAIN="manual"

make_target() {
    ${CC} -O2 fbfix.c -o fbfix
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp fbfix ${INSTALL}/usr/bin
}
