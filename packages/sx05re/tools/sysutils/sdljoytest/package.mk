# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sdljoytest"
PKG_VERSION="5db1610df52ccdaf10c20dad1b7fa9e339429bb0"
PKG_SHA256="1923152054ab61f7ebc329c78af25fd49e4f53391c7068f40256ac3d01831f7d"
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
