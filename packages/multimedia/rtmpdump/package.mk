# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rtmpdump"
sudo apt install build-essential gcc g++ make cmakesudo apt update
sudo apt install -y build-essential gcc g++ make cmakePKG_VERSION="f1b83c10d8beb43fcc70a6e88cf4325499f25857"
#PKG_SHA256="97b0d3d20d980ac38aa9729e60e926f101854b59960fd50c82686bfdd3d420ff"
PKG_LICENSE="GPL"
PKG_SITE="http://rtmpdump.mplayerhq.hu/"
PKG_URL="https://github.com/mstorsjo/rtmpdump/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib openssl"
PKG_LONGDESC="rtmpdump is a toolkit for RTMP streams."
PKG_BUILD_FLAGS="+pic"

make_target() {
  make prefix=/usr \
       incdir=/usr/include/librtmp \
       libdir=/usr/lib \
       mandir=/usr/share/man \
       CC="${CC}" \
       LD="${LD}" \
       AR="${AR}" \
       SHARED=no \
       CRYPTO="OPENSSL" \
       OPT="" \
       XCFLAGS="${CFLAGS}" \
       XCFLAGS="${CFLAGS} -Wno-unused-but-set-variable -Wno-unused-const-variable" \
       XLDFLAGS="${LDFLAGS}" \
       XLIBS="-lm"
}

makeinstall_target() {
  make DESTDIR=${SYSROOT_PREFIX} \
       prefix=/usr \
       incdir=/usr/include/librtmp \
       libdir=/usr/lib \
       mandir=/usr/share/man \
       CC="${CC}" \
       LD="${LD}" \
       AR="${AR}" \
       SHARED=no \
       CRYPTO="OPENSSL" \
       OPT="" \
       XCFLAGS="${CFLAGS}" \
       XLDFLAGS="${LDFLAGS}" \
       XLIBS="-lm" \
       install

  make DESTDIR=${INSTALL} \
       prefix=/usr \
       incdir=/usr/include/librtmp \
       libdir=/usr/lib \
       mandir=/usr/share/man \
       CC="${CC}" \
       LD="${LD}" \
       AR="${AR}" \
       SHARED=no \
       CRYPTO="OPENSSL" \
       OPT="" \
       XCFLAGS="${CFLAGS}" \
       XLDFLAGS="${LDFLAGS}" \
       XLIBS="-lm" \
       install
}
