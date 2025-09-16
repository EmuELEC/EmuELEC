# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sonicmania"
PKG_VERSION="f2120842a15a5721d88907bf98edee670c10f79d"
PKG_ARCH="any"
PKG_SITE="https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 portaudio"
PKG_SHORTDESC="Sonic Mania Decompilation"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="-DRETRO_SUBSYSTEM=SDL2"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin/sonic_mania
echo "${PKG_BUILD}"
cp ${PKG_BUILD}/.${TARGET_NAME}/dependencies/RSDKv5/RSDKv5U ${INSTALL}/usr/bin/sonicmania
cp ${PKG_BUILD}/.${TARGET_NAME}/dependencies/RSDKv5/libGame.so ${INSTALL}/usr/bin/sonic_mania/Game.so

mkdir -p ${INSTALL}/usr/config/emuelec/configs/sonicmania
cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/sonicmania
} 
