# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="retrorun"
PKG_VERSION="c83f1095351c82be9b04cdebd61ca0e03ef4cfb7"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/navy1978/retrorun-go2"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain libgo2 libdrm"
PKG_TOOLCHAIN="make"

pre_configure_target() {
	CFLAGS+=" -I$(get_build_dir libdrm)/include/drm"
	CFLAGS+=" -I$(get_build_dir linux)/include/uapi"
	CFLAGS+=" -I$(get_build_dir linux)/tools/include"
	PKG_MAKE_OPTS_TARGET=" config=release ARCH=" 

	sed -i "s|/storage/.config/distribution/|/emuelec/|g" ${PKG_BUILD}/src/main.cpp
	rm ${PKG_BUILD}/retrorun
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/
	if [ ${ARCH} == "arm" ]; then
		cp retrorun $INSTALL/usr/bin/retrorun32
	else
		cp retrorun ${INSTALL}/usr/bin/retrorun
	fi
	cp ${PKG_BUILD}/setting.cfg ${INSTALL}/usr/config/emuelec/configs/retrorun.cfg
	
	
}
