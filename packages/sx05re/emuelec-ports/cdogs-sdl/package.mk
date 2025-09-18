# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="cdogs-sdl"
PKG_VERSION="c337d85e16fdd36cdaf455e5779ecbdfc0300c6f"
PKG_ARCH="any"
PKG_SITE="https://github.com/cxong/cdogs-sdl"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 python3-protobuf:host"
PKG_SHORTDESC="Classic overhead run-and-gun game"
PKG_TOOLCHAIN="cmake-make"

pre_configure_target() {
sed -i "s|-Werror|-Wno-error|" ${PKG_BUILD}/CMakeLists.txt
PKG_CMAKE_OPTS_TARGET=" -DCDOGS_DATA_DIR=/storage/roms/ports/cdogs-sdl/ -DBUILD_EDITOR=OFF -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/.${TARGET_NAME}/src/cdogs-sdl ${INSTALL}/usr/bin
cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
} 
