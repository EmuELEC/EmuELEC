# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="ee_utils"
PKG_VERSION="v1"
PKG_LICENSE="Public Domain"
PKG_SITE="https://emuelec.org"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Misc EmuELEC specific utils"
PKG_TOOLCHAIN="manual"

make_target() {
	mkdir -p bin
    ${CC} -O2 ees.c -o bin/ees
    ${CC} -O2 ee_asd.c -o bin/ee_asd
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp bin/* ${INSTALL}/usr/bin
}
