# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="falloutce2"
PKG_VERSION="ec0685ea19dd636e38d81fd8695290b3b4b5cc22"
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/alexbatalov/fallout2-ce"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Game port of Fallout 2 using SDL2"
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp ${PKG_BUILD}/.${TARGET_NAME}/fallout2-ce ${INSTALL}/usr/bin
cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
mkdir -p ${INSTALL}/usr/config/emuelec/configs/falloutce2
cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/falloutce2
}
