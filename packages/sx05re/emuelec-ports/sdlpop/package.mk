# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sdlpop"
PKG_VERSION="bb0c6f3da464106b5fc931925fcf338f6c4939b9"
PKG_SHA256="e2d7f80397a3f8b730c4255416c43107cd34b59541dd67610597045fbb7d2b6c"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/NagyD/SDLPoP"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image"
PKG_SHORTDESC="Prince of Persia SDL"
PKG_LONGDESC="An open-source port of Prince of Persia, based on the disassembly of the DOS version."
PKG_TOOLCHAIN="make"

pre_configure_target() {
sed -i "s/start_fullscreen = false/start_fullscreen = true/" "${PKG_BUILD}/SDLPoP.ini"
sed -i "s/enable_info_screen = true;/enable_info_screen = false;/" "${PKG_BUILD}/SDLPoP.ini"
}

make_target() {
	cd ${PKG_BUILD}/src/
	mkdir -p build
	cd build/
	cmake ..
	make CC=cc
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/SDLPoP
	mkdir -p ${INSTALL}/usr/bin
	cp -r ${PKG_BUILD}/* ${INSTALL}/usr/config/emuelec/configs/SDLPoP/
	mv "${INSTALL}/usr/config/emuelec/configs/SDLPoP/prince" "${INSTALL}/usr/bin/"
	rm -rf ${INSTALL}/usr/config/emuelec/configs/SDLPoP/src
	rm -rf ${INSTALL}/usr/config/emuelec/configs/SDLPoP/.gitignore
	rm -rf ${INSTALL}/usr/config/emuelec/configs/SDLPoP/.editorconfig
}
