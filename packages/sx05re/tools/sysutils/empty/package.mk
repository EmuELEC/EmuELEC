# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="empty"
PKG_VERSION="0.6.20b"
PKG_SHA256="7e6636e400856984c4405ce7bd0843aaa3329fa3efd20c58df8400a9eaa35f09"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://empty.sourceforge.net/"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_URL="http://downloads.sourceforge.net/sourceforge/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_SECTION="sysutils"
PKG_SHORTDESC="Run applications under pseudo-terminal sessions"
PKG_LONGDESC="Run applications under pseudo-terminal sessions"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

make_target() {
  make CC=${CC}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp empty ${INSTALL}/usr/bin/
}
