# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="bennugd-monolithic"
PKG_VERSION="60ee3389efcf9b402d66035e87f33d17d70cbd83"
PKG_ARCH="arm"
PKG_SITE="https://github.com/christianhaitian/bennugd-monolithic"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libvorbisidec SDL2 SDL2_mixer libpng tre"
PKG_SHORTDESC="Use for executing bennugd games like Streets of Rage Remake "
PKG_TOOLCHAIN="cmake-make"


chainfile="cmake-aarch64-libreelec-linux-gnueabi.conf"

if [ ${ARCH} == "arm" ]; then
	chainfile="cmake-${TARGET_NAME}.conf"
fi

pre_configure_target() {
PKG_CMAKE_SCRIPT="${PKG_BUILD}/projects/cmake/bgdc/CMakeLists.txt"
cd ${PKG_BUILD}/projects/cmake/bgdc/
cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN}/etc/${chainfile} -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel ${PKG_CMAKE_SCRIPT}
make

PKG_CMAKE_SCRIPT="${PKG_BUILD}/projects/cmake/bgdi/CMakeLists.txt"
cd ${PKG_BUILD}/projects/cmake/bgdi/
cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN}/etc/${chainfile} -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel ${PKG_CMAKE_SCRIPT}
make
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp ${PKG_BUILD}/projects/cmake/bgdi/bgdi ${INSTALL}/usr/bin
cp ${PKG_BUILD}/projects/cmake/bgdc/bgdc ${INSTALL}/usr/bin
} 
