# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="getscancodes"
PKG_VERSION="1.0"
PKG_SHA256="5f4e2ab22dc3890392ab8870fb79bbebdfd39b34dcd5bafcb51edee554855d34"
PKG_LICENSE="GPL"
PKG_SITE="http://keytouch.sourceforge.net"
PKG_URL="${SOURCEFORGE_SRC}/keytouch/getscancodes-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Shows the scancode of the pressed or released key."
PKG_BUILD_FLAGS="-sysroot"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="CC=${CC}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -p getscancodes ${INSTALL}/usr/bin
}
