# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="liberation-fonts-ttf"
PKG_VERSION="2.1.5"
PKG_SHA256="7191c669bf38899f73a2094ed00f7b800553364f90e2637010a69c0e268f25d0"
PKG_LICENSE="OFL-1.1"
PKG_SITE="https://github.com/liberationfonts/liberation-fonts"
PKG_URL="https://github.com/liberationfonts/liberation-fonts/files/7261482/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain util-macros"
PKG_LONGDESC="This packages included the high-quality and open-sourced TrueType vector fonts."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/fonts/liberation
    cp *.ttf ${INSTALL}/usr/share/fonts/liberation
}

post_install() {
  mkfontdir ${INSTALL}/usr/share/fonts/liberation
  mkfontscale ${INSTALL}/usr/share/fonts/liberation
}
