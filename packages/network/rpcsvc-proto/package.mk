# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rpcsvc-proto"
PKG_VERSION="1.4.1"
PKG_SHA256="9429e143bb8dd33d34bf0663f571d4d4a1103e1afd7c49791b367b7ae1ef7f35"
PKG_LICENSE="BSD"
PKG_SITE="http://nfs.sourceforge.net/"
PKG_URL="https://github.com/thkukuk/rpcsvc-proto/releases/download/v$PKG_VERSION/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_HOST="toolchain"
PKG_DEPENDS_TARGET="toolchain rpcsvc-proto:host"
PKG_LONGDESC="The rpcsvc-proto package contains the rcpsvc protocol.x files and headers."

pre_configure_host() {
  cd $PKG_BUILD
  rm -rf .$HOST_NAME
}

pre_configure_target() {
  cd $PKG_BUILD
  rm -rf .$TARGET_NAME
}

make_host() {
  make rpcgen -C rpcgen
}

makeinstall_target() {
  : #
}
