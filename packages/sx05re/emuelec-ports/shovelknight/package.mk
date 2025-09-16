# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="shovelknight"
PKG_VERSION="1.0"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Script file to run Shovel Knight"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp shovelknight.sh ${INSTALL}/usr/bin
}
