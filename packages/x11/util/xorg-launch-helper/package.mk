# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="xorg-launch-helper"
PKG_VERSION="4"
PKG_SHA256="a7f8809a1810212506893ac5c62d8d17fee7a980fb10d59d1bef36f694767be5"
PKG_LICENSE="GPL-2"
PKG_SITE="https://github.com/sofar/xorg-launch-helper"
PKG_URL="http://foo-projects.org/~sofar/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="Xorg-launch-helper is a small utility that transforms the X server process (XOrg) into a daemon."
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
  export LIBS="-lsystemd"
}

post_makeinstall_target() {
  # do not install systemd services
  rm -rf ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_DIR}/scripts/xorg-launch ${INSTALL}/usr/bin
}
