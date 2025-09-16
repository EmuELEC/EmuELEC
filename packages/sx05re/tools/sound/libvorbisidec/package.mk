# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="libvorbisidec"
PKG_VERSION="a76e41f6ece93d10deac5f9ef3a84dce5b9c2a84"
PKG_SHA256="54c4cfaf442885575261d7b310b2dfa79e4fbf095aaf34de07875b024e499991"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/sezero/tremor"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libogg freetype"
PKG_LONGDESC="libvorbisidec"
PKG_TOOLCHAIN="make"


make_target() {
cd ${PKG_BUILD}
./autogen.sh HAVE_OGG=no --disable-mmx --prefix=/usr --datadir=/usr/share/ --datarootdir=/usr/share/ --host=armv8a-libreelec-linux --enable-fb --enable-freetype --with-freetype-prefix=${SYSROOT_PREFIX}/usr/ --enable-slang
make 
}
