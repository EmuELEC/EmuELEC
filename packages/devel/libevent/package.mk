# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libevent"
PKG_VERSION="2.1.11-stable"
PKG_SHA256="a65bac6202ea8c5609fd5c7e480e6d25de467ea1917c08290c521752f147283d"
PKG_LICENSE="BSD"
PKG_SITE="https://libevent.org"
PKG_URL="https://github.com/libevent/libevent/releases/download/release-$PKG_VERSION/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl"
PKG_LONGDESC="The libevent API provides a mechanism to execute a callback function when a specific event occurs."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--disable-static \
                           --disable-libevent-regress \
                           --disable-samples \
                           --enable-openssl"

post_unpack() {
  # https://github.com/libevent/libevent/issues/863
  #  Uninstall.cmake.in is missing from 2.1.11 release
  touch $PKG_BUILD/cmake/Uninstall.cmake.in
}

post_makeinstall_target() {
  rm -f $INSTALL/usr/bin/event_rpcgen.py
}
