# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="celeste"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Script file to run celeste (itch.io linux version)"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp celeste.sh ${INSTALL}/usr/bin
mkdir -p ${INSTALL}/usr/config/emuelec/configs
cp celeste.tar.xz ${INSTALL}/usr/config/emuelec/configs
}
