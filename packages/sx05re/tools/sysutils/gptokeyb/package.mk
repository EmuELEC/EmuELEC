# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="gptokeyb"
PKG_VERSION="9cf438275c87ca3542b2ce34b1a043663d3be005"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/EmuELEC/gptokeyb"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libevdev"
PKG_SECTION="emuelec"
PKG_SHORTDESC="Gamepad to Keyboard/mouse/xbox360 emulator"
PKG_TOOLCHAIN="make"

pre_configure_target() {
sed -i "s|\`sdl2-config|\`${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
sed -i "s|\-I/usr/include/libevdev-1.0|\-I${SYSROOT_PREFIX}/usr/include/libevdev-1.0|g" Makefile
}

makeinstall_target(){
mkdir -p ${INSTALL}/usr/bin
cp gptokeyb ${INSTALL}/usr/bin

mkdir -p ${INSTALL}/usr/config/emuelec/configs/gptokeyb
cp -rf ${PKG_BUILD}/configs/*.gptk ${INSTALL}/usr/config/emuelec/configs/gptokeyb

}
