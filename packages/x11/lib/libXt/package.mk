# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libXt"
PKG_VERSION="1.2.1"
PKG_SHA256="679cc08f1646dbd27f5e48ffe8dd49406102937109130caab02ca32c083a3d60"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros libX11 libSM"
PKG_LONGDESC="libXt provides the X Toolkit Intrinsics library, an abstract widget library upon which other toolkits are based."

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --with-gnu-ld \
                           --enable-malloc0returnsnull"

pre_make_target() {
  make -C util CC=${HOST_CC} \
               CFLAGS="${HOST_CFLAGS} " \
               LDFLAGS="${HOST_LDFLAGS}" \
               makestrs
}
