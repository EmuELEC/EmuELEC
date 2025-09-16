# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="supertuxkart"
PKG_VERSION="fab79150111944c9e33396db68eb5de84f2efeaa"
PKG_SHA256="c2b0d7781331e1bd717f2eeaf9f5ca56f314d4bb5136a8dd9c6fe45777d31022"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/supertuxkart/stk-code"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 harfbuzz"
PKG_LONGDESC="SuperTuxKart is a free kart racing game. It focuses on fun and not on realistic kart physics. Instructions can be found on the in-game help page."

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET+=" -DNO_SHADERC=on -DBUILD_RECORDER=0 -DUSE_WIIUSE=OFF -DCHECK_ASSETS=off -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp ${PKG_BUILD}/.${TARGET_NAME}/bin/supertuxkart ${INSTALL}/usr/bin/
cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
