# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="broguece"
PKG_VERSION="dfd321ed82b104ed141323baefc6fef1c7b60315"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="AGPL3"
PKG_SITE="https://github.com/tmewett/BrogueCE"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image"
PKG_LONGDESC="Brogue: Community Edition - a community-lead fork of the much-loved minimalist roguelike game"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"


pre_configure_target() {
	sed -i "s|#include <SDL_image.h>|#include <SDL2/SDL_image.h>|" ${PKG_BUILD}/src/platform/tiles.c ${PKG_BUILD}/src/platform/sdl2-platform.c
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
	cp -rf ${PKG_BUILD}/bin/assets ${INSTALL}/usr/bin
	cp -rf ${PKG_BUILD}/bin/brogue ${INSTALL}/usr/bin
}
