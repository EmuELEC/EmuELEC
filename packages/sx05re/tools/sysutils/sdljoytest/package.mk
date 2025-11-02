# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sdljoytest"
PKG_VERSION="2daaf52122303197bfb6502a73280cfa65fe0524"
PKG_SHA256="ff45b1677361e4fd361c1372c4804f1a8eca1dade048b4f9f32126d2cdc9dfd9"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/EmuELEC/sdljoytest"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Test joystick with SDL2 in Linux"
PKG_TOOLCHAIN="make"

pre_configure_target() {
sed -i "s|gcc|${CC}|" Makefile
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -rf test_gamepad_SDL2 ${INSTALL}/usr/bin/sdljoytest
cp -rf map_gamepad_SDL2 ${INSTALL}/usr/bin/sdljoymap
cp -rf gamepad_info ${INSTALL}/usr/bin/gamepad_info
}
