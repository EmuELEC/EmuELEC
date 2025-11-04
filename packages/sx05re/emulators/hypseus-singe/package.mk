# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hypseus-singe"
PKG_VERSION="8397498bccd5dd8afc55b2200d533d66e17be56f"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/DirtBagXon/hypseus-singe"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libvorbis SDL2_ttf SDL2_image"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" ./src"

pre_configure_target() {
mkdir -p ${INSTALL}/usr/config/emuelec/configs/hypseus
ln -fs /storage/roms/daphne/roms ${INSTALL}/usr/config/emuelec/configs/hypseus/roms
ln -fs /usr/share/daphne/sound ${INSTALL}/usr/config/emuelec/configs/hypseus/sound
ln -fs /usr/share/daphne/fonts ${INSTALL}/usr/config/emuelec/configs/hypseus/fonts
ln -fs /usr/share/daphne/pics ${INSTALL}/usr/config/emuelec/configs/hypseus/pics
}

post_makeinstall_target() {
cp -rf ${PKG_BUILD}/doc/hypinput.ini ${INSTALL}/usr/config/emuelec/configs/hypseus/hypinput.ini
cp -rf ${PKG_BUILD}/doc/hypinput_gamepad.ini ${INSTALL}/usr/config/emuelec/configs/hypseus/hypinput_gamepad.ini
ln -fs /storage/.config/emuelec/configs/hypseus/hypinput.ini ${INSTALL}/usr/share/daphne/hypinput.ini
}
