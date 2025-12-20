# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="bootini"
PKG_VERSION=""
PKG_LICENSE="various"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

makeinstall_target() {

	mkdir -p $INSTALL/usr/share/bootloader
	
if [ "$DEVICE" == "OdroidGoAdvance" ]; then
	cp boot_oga.ini $INSTALL/usr/share/bootloader/boot.ini
elif [ "$DEVICE" == "GameForce" ]; then
	cp boot_gameforce.ini $INSTALL/usr/share/bootloader/boot.ini
fi

}
