# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mesa-demos"
PKG_VERSION="8.4.0"
PKG_SHA256="01e99c94a0184e63e796728af89bfac559795fb2a0d6f506fa900455ca5fff7d"
PKG_ARCH="x86_64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.mesa3d.org/"
PKG_URL="ftp://ftp.freedesktop.org/pub/mesa/demos/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libX11 mesa glu glew"
PKG_LONGDESC="Mesa 3D demos - installed are the well known glxinfo and glxgears."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--without-glut"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -P src/xdemos/glxdemo ${INSTALL}/usr/bin
    cp -P src/xdemos/glxgears ${INSTALL}/usr/bin
    cp -P src/xdemos/glxinfo ${INSTALL}/usr/bin
}
