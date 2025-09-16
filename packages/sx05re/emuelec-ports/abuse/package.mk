# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="abuse"
PKG_VERSION="9d1f66f57377859bae10e28eabebea0b9c750490"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Xenoveritas/abuse"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer libepoxy"
PKG_LONGDESC="Abuse SDL port originally from Crack-Dot-Com and released into the public domain"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release"

pre_configure_target() {
	if [ ! -e ${SOURCES}/${PKG_NAME}/abuse-0.8.tar.gz ]; then
		wget http://abuse.zoy.org/raw-attachment/wiki/download/abuse-0.8.tar.gz -P ${SOURCES}/${PKG_NAME}
	fi

	tar -xf ${SOURCES}/${PKG_NAME}/abuse-0.8.tar.gz -C ${SOURCES}/${PKG_NAME}/
	rm -rf ${PKG_BUILD}/data/{music,sfx}
	mv ${SOURCES}/${PKG_NAME}/abuse-0.8/data/music ${PKG_BUILD}/data
	mv ${SOURCES}/${PKG_NAME}/abuse-0.8/data/sfx ${PKG_BUILD}/data
	rm -rf ${SOURCES}/${PKG_NAME}/abuse-0.8/
}

post_makeinstall_target() {	
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/
	cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/
}
