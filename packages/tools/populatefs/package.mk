# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="populatefs"
PKG_VERSION="1.0"
PKG_SHA256="e5845404188b5da3afb11229ecb38646cc1562b61400035774dbc237c3b706d2"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lipnitsk/populatefs"
PKG_URL="https://github.com/lipnitsk/${PKG_NAME}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="e2fsprogs:host"
PKG_LONGDESC="populatefs: Tool for replacing genext2fs when creating ext4 images"
PKG_BUILD_FLAGS="+pic:host"

make_host() {
  make EXTRA_LIBS="-lcom_err -lpthread"
}

makeinstall_host() {
  ${STRIP} src/populatefs

  mkdir -p ${TOOLCHAIN}/sbin
  cp src/populatefs ${TOOLCHAIN}/sbin
}
