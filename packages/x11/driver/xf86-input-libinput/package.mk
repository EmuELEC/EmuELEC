# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xf86-input-libinput"
PKG_VERSION="1.2.1"
PKG_SHA256="8151db5b9ddb317c0ce92dcb62da9a8db5079e5b8a95b60abc854da21e7e971b"
PKG_LICENSE="MIT"
PKG_SITE="http://www.freedesktop.org/wiki/Software/libinput/"
PKG_URL="http://xorg.freedesktop.org/archive/individual/driver/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libinput"
PKG_LONGDESC="This is an X driver based on libinput."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--with-xorg-module-dir=${XORG_PATH_MODULES}"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/X11/xorg.conf.d
    cp ${PKG_BUILD}/conf/*-libinput.conf ${INSTALL}/usr/share/X11/xorg.conf.d
}
