# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="351Files"
PKG_VERSION="492961726abb04ebefa58f7dda47b7040f3bd088"
PKG_SHA256="249ef2842fb28fc9a1296f25a35b7f02ac5a5ef7a472b9a4e1a977722cf39643"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/EmuELEC/351Files"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_gfx SDL2_ttf freetype file"
PKG_LONGDESC="File Manager"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i "s|ifeq (\$(DEVICE),PC)||g" Makefile
  sed -i "s|endif||g" Makefile
  sed -i "s|START_PATH = \$(PWD)||g" Makefile
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
  sed -i "s|g++|\$(CXX)|g" Makefile

	EEDV="PC"

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	EEDV="EE_HH"
fi

  PKG_MAKE_OPTS_TARGET=" START_PATH="/storage" DEVICE=${EEDV} RES_PATH="/emuelec/configs/fm/res""
}



makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/fm
  cp 351Files ${INSTALL}/usr/bin/
  cp -rf res ${INSTALL}/usr/config/emuelec/configs/fm/
  
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/
  
  
}
