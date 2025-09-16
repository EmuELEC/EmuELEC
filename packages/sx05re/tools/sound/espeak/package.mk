# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="espeak"
PKG_VERSION="1.48.04-source"
PKG_SHA256="bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"
PKG_LICENSE="GPL"
PKG_SITE="http://espeak.sourceforge.net/"
PKG_URL="http://sourceforge.net/projects/espeak/files/espeak/espeak-1.48/$PKG_NAME-$PKG_VERSION.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Text to Speech engine for English, with support for other languages"
PKG_TOOLCHAIN="manual"

REALSYSROOT=${SYSROOT_PREFIX}

pre_make_target() {
  cp src/portaudio19.h src/portaudio.h
}

make_target() {
  make -C src \
       CXXFLAGS="$CXXFLAGS" \
       LDFLAGS="$LDFLAGS" \
       AUDIO=""
}

makeinstall_target() {
  make -C src \
       CXXFLAGS="$CXXFLAGS" \
       LDFLAGS="$LDFLAGS" \
       AUDIO="" \
       DESTDIR=$INSTALL install
}

post_makeinstall_target() {
	mkdir -p ${REALSYSROOT}/usr/include/espeak
	cp ${INSTALL}/usr/lib/* ${REALSYSROOT}/usr/lib/
	cp ${PKG_BUILD}/src/speak_lib.h ${REALSYSROOT}/usr/include/espeak
}
