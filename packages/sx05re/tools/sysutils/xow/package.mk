# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xow"
PKG_VERSION="d335d6024f8380f52767a7de67727d9b2f867871"
PKG_SHA256="b841bf298e2e8904033629cf5685938f90add9d9d3a826f1670ac9990b6f1f76"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/medusalix/xow"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linux driver for the Xbox One wireless dongle  "
PKG_TOOLCHAIN="make"

pre_configure_target() {
PKG_MAKE_OPTS_TARGET=" BUILD=RELEASE"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp xow ${INSTALL}/usr/bin
}
