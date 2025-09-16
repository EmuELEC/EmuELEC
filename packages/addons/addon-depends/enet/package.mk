# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="enet"
PKG_VERSION="8d69c5abe4b699e7077395e01927bd102b3ba597" # 12 Jun 2021
PKG_SHA256="4da28dc923828f2241f9086009c87d9679cb52bb3085305754cbcac33a06f312"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/cgutman/enet/"
PKG_URL="https://github.com/cgutman/enet/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A network communication layer on top of UDP (User Datagram Protocol)."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"

post_makeinstall_target() {
  rm -r ${INSTALL}
}
