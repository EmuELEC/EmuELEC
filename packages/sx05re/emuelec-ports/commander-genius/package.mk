# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="commander-genius"
PKG_VERSION="6f7e67ad07323416f798046d62be8e10e856d62a"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://gitlab.com/Dringgstein/Commander-Genius"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain boost Python3 SDL2 SDL2_image SDL2_mixer"
PKG_SECTION="libretro"
PKG_SHORTDESC="Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DUSE_SDL2=ON -DBUILD_TARGET=LINUX -DCMAKE_BUILD_TYPE=Release -DUSE_OPENGL=OFF -DDOWNLOADER=OFF -DNOTYPESAVE=ON"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/config/emuelec/configs/CommanderGenius
cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/CommanderGenius/
cp -rf ${PKG_BUILD}/vfsroot/* ${INSTALL}/usr/config/emuelec/configs/CommanderGenius/

mkdir -p ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/.${TARGET_NAME}/src/CGeniusExe ${INSTALL}/usr/bin
}
