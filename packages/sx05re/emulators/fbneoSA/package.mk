# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbneoSA"
PKG_VERSION="ca8768dae3a2a5ba7d034ce54fe462f4f35cecbe"
PKG_ARCH="aarch64"
PKG_LICENSE="Custom"
PKG_SITE="https://github.com/finalburnneo/FBNeo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 gl4es"
PKG_LONGDESC="https://github.com/finalburnneo/FBNeo/blob/master/src/license.txt"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET=" sdl2 RELEASEBUILD=1"

pre_configure_target() {
sed -i "s|\`sdl2-config|\`${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" makefile.sdl2
sed -i "s|objdir	= obj/|objdir	= ${PKG_BUILD}/obj/|" makefile.sdl2
sed -i "s|srcdir	= src/|srcdir	= ${PKG_BUILD}/src/|" makefile.sdl2
sed -i "s|CC	= gcc|#CC	= gcc|" makefile.sdl2
export LDFLAGS+=" -L$(get_install_dir gl4es)/usr/lib"
unset MAKELEVEL
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/fbneo ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/src/license.txt ${INSTALL}/usr/bin/fbneo_license.txt
cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
