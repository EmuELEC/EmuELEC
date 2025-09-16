# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="iftop"
PKG_VERSION="77901c8c53e01359d83b8090aacfe62214658183"
PKG_SHA256="f2728741f1bd2099d325271b4b2564a696dbce7c23401360ac6c9841cbda1108"
PKG_LICENSE="GPL"
PKG_SITE="http://www.ex-parrot.com/pdw/iftop/"
PKG_URL="https://code.blinkace.com/pdw/iftop/-/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses libpcap libnl"
PKG_LONGDESC="A tool to display bandwidth usage on an interface."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

pre_build_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

pre_configure_target() {
  export LIBS="-lpcap -lnl-3 -lnl-genl-3 -lncurses"
}
