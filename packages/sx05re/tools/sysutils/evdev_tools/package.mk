# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present BetaXOi (https://github.com/BetaXOi)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="evdev_tools"
PKG_VERSION=""
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/BetaXOi"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec"
PKG_LONGDESC="A set of small evdev tools by https://github.com/BetaXOi"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"
PKG_TOOLCHAIN="make"
 
make_target() {
	cd ${PKG_BUILD}/
	${CC} -O2 evtest.c -o evtest
	${CC} -O2 send.c -o evsend
	${CC} -O2 remap.c -o evremap
	${CC} -O2 evkill.c -o evkill
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
	cp ${PKG_BUILD}/evtest ${INSTALL}/usr/bin
	cp ${PKG_BUILD}/evsend ${INSTALL}/usr/bin
	cp ${PKG_BUILD}/evremap ${INSTALL}/usr/bin
	cp ${PKG_BUILD}/evkill ${INSTALL}/usr/bin
} 
