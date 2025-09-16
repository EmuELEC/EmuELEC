# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="tmntsr"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain progressor"
PKG_SHORTDESC="Script file to run teenage mutant ninja turtles shredder's revenge"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp tmntsr.sh ${INSTALL}/usr/bin
mkdir -p ${INSTALL}/usr/config/emuelec/configs
cp tmntsr.tar.xz ${INSTALL}/usr/config/emuelec/configs
}
