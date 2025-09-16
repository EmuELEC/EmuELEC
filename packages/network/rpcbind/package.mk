# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rpcbind"
PKG_VERSION="1.2.6"
PKG_SHA256="5613746489cae5ae23a443bb85c05a11741a5f12c8f55d2bb5e83b9defeee8de"
PKG_LICENSE="OSS"
PKG_SITE="http://rpcbind.sourceforge.net/"
PKG_URL="${SOURCEFORGE_SRC}/rpcbind/rpcbind/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libtirpc systemd"
PKG_LONGDESC="The rpcbind utility is a server that converts RPC program numbers into universal addresses."

PKG_CONFIGURE_OPTS_TARGET="ac_cv_header_rpcsvc_mount_h=no \
                           --disable-warmstarts \
                           --disable-libwrap \
                           --enable-rmtcalls \
                           --with-statedir=/tmp \
                           --with-rpcuser=root"

post_install() {
  enable_service rpcbind.service
}
