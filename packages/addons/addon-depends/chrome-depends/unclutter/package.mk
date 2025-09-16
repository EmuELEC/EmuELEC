# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="unclutter"
PKG_VERSION="1.09"
PKG_SHA256="3a53575fe2a75a34bc9a2b0ad92ee0f8a7dbedc05d8783f191c500060a40a9bd"
PKG_LICENSE="Public Domain"
PKG_SITE="https://sourceforge.net/projects/unclutter/"
PKG_URL="https://sourceforge.net/projects/unclutter/unclutter/source_${PKG_VERSION}/unclutter-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libX11"
PKG_LONGDESC="Unclutter runs in the background of an X11 session and hides the X11 Cursor."

make_target() {
  rm -f Makefile
  LDFLAGS="${LDFLAGS} -lX11" ${MAKE} unclutter
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  install -m 755 unclutter ${INSTALL}/usr/bin/
}
