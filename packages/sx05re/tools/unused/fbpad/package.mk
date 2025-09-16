# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbpad"
PKG_VERSION="52b6bed1d8ce6357992e8fff6d53fef3c9fb047c"
PKG_SHA256="65ce00aa9709c4fc747499b0c5a8e0d084fa134678a3d781a7634f8d8a2f452f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/aligrudi/fbpad"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A small Linux framebuffer virtual terminal http://litcave.rudi.ir/"
PKG_TOOLCHAIN="auto"

export CC=${CC}
export CFLAGS="-Wall -O2"

make_target() {
make fbpad

if [ "${DEVICE}" == "Amlogic-old" ]; then
	sed -i "s|unsigned int|unsigned short|" ${PKG_BUILD}/conf.h
	mv fbpad fbpad32
	make fbpad
fi 
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
if [ "${DEVICE}" == "Amlogic-old" ]; then
	cp fbpad32 ${INSTALL}/usr/bin/fbpad
	cp fbpad ${INSTALL}/usr/bin/fbpad16
else
	cp fbpad ${INSTALL}/usr/bin/fbpad
fi
	mkdir -p ${INSTALL}/usr/config/emuelec/configs
	cp courr.tf ${INSTALL}/usr/config/emuelec/configs
	mkdir -p ${INSTALL}/usr/share/terminfo
	tic -x ${PKG_BUILD}/fbpad-256 -o ${INSTALL}/usr/share/terminfo
	}

