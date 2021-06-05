# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hypseus-singe"
PKG_VERSION="6f93c205973644f194d8599c04e7642a9af785a4"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/DirtBagXon/hypseus-singe"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git libvorbis"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" ./src"

pre_configure_target() {
mkdir -p $INSTALL/usr/config/emuelec/configs/hypseus
ln -fs /storage/roms/daphne/roms $INSTALL/usr/config/emuelec/configs/hypseus/roms
ln -fs /usr/share/daphne/sound $INSTALL/usr/config/emuelec/configs/hypseus/sound
ln -fs /usr/share/daphne/fonts $INSTALL/usr/config/emuelec/configs/hypseus/fonts
ln -fs /usr/share/daphne/pics $INSTALL/usr/config/emuelec/configs/hypseus/pics
}

post_makeinstall_target() {

if [ "${DEVICE}" == "GameForce" ]; then
	cp -rf ${PKG_DIR}/config/hypinput_gf.ini $INSTALL/usr/config/emuelec/configs/hypseus/hypinput.ini
else
	cp -rf $PKG_BUILD/doc/hypinput.ini $INSTALL/usr/config/emuelec/configs/hypseus/
fi

ln -fs /storage/.config/emuelec/configs/hypseus/hypinput.ini $INSTALL/usr/share/daphne/hypinput.ini
}