# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="dolphinSA"
PKG_VERSION="3c4d4fcd09173ea070dc812ab5d64ca3a3af5f29"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/dolphin-emu/dolphin"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain qt-everywhere libevdev"
PKG_LONGDESC="Dolphin is a GameCube / Wii emulator, allowing you to play games for these two platforms on PC with improvements. "
PKG_BUILD_FLAGS="lto"

# Configure CMake for LTO with BFD linker
PKG_CMAKE_OPTS_TARGET=" -DENABLE_LTO=ON \
                        -DCMAKE_EXE_LINKER_FLAGS='-fuse-ld=bfd' \
                        -DCMAKE_SHARED_LINKER_FLAGS='-fuse-ld=bfd' \
                        -DDISTRIBUTOR='EmuELEC' \
                        -DBUILD_SHARED_LIBS=OFF \
                        -DTHREADS_PTHREAD_ARG=OFF \
                        -DENABLE_FBDEV=ON \
                        -DENABLE_EGL=ON \
                        -DENABLE_X11=OFF \
                        -DENABLE_NOGUI=ON \
                        -DUSE_DISCORD_PRESENCE=OFF \
                        -DENABLE_QT=OFF \
                        -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
export CXXFLAGS="`echo ${CXXFLAGS} | sed -e "s|-O.|-O3|g"`"
mkdir -p ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/.${TARGET_NAME}/Binaries/dolphin-emu-nogui ${INSTALL}/usr/bin
cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

mkdir -p ${INSTALL}/usr/config/emuelec/configs/dolphin-emu
cp -rf ${PKG_BUILD}/Data/Sys/* ${INSTALL}/usr/config/emuelec/configs/dolphin-emu
cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/dolphin-emu
}
