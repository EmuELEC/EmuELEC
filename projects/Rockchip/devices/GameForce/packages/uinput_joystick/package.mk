# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="uinput_joystick"
PKG_VERSION="bea7d56f4947b547db2b827640bc9966fe770f84"
PKG_SITE="https://github.com/shantigilbert/uinput_joystick"
PKG_URL="$PKG_SITE.git"
PKG_LICENSE="Apachev2+"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Rockchip uinput joystick for r602"
PKG_TOOLCHAIN="make"

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin/
	cp $PKG_BUILD/uinput_joystick $INSTALL/usr/bin/uinput_joystick
	cp $PKG_BUILD/fftest $INSTALL/usr/bin/fftest
}

post_install() {  
	enable_service uinput_joystick.service
}
