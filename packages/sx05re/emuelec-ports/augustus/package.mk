# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="augustus"
PKG_VERSION="8a136244e8edf87e7b061d6da3fb36457e1d6f03"
PKG_SHA256="49bb5fdd6e2ba11821fe02a4678283d393aab0dff6bc8cb62fd577b5848df345"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/Keriew/augustus"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="An open source re-implementation of Caesar III"
PKG_TOOLCHAIN="cmake-make"

pre_configure_target() {
# Just setting the version
sed -i "s|unknown development version|Version: ${PKG_VERSION:0:7} - ${DISTRO}|g" ${PKG_BUILD}/CMakeLists.txt
}
