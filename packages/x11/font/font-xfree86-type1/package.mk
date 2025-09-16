# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="font-xfree86-type1"
PKG_VERSION="1.0.4"
PKG_SHA256="caebf42aec7be7f3bd40e0f232d6f34881b853dc84acfcdf7458358701fbe34a"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/releases/individual/font/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros"
PKG_LONGDESC="A Xfree86 Inc. Type1 font."

PKG_CONFIGURE_OPTS_TARGET="--with-fontrootdir=/usr/share/fonts"

post_install() {
  mkfontdir ${INSTALL}/usr/share/fonts/Type1
  mkfontscale ${INSTALL}/usr/share/fonts/Type1
}
