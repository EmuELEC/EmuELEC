# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libsamplerate"
PKG_VERSION="0.2.2"
PKG_SHA256="3258da280511d24b49d6b08615bbe824d0cacc9842b0e4caf11c52cf2b043893"
PKG_LICENSE="GPL"
PKG_SITE="http://libsndfile.github.io/libsamplerate/"
PKG_URL="https://github.com/libsndfile/libsamplerate/releases/download/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Sample Rate Converter for audio."
PKG_TOOLCHAIN="autotools"

# package specific configure options
PKG_CONFIGURE_OPTS_TARGET="--disable-shared \
                           --enable-static \
                           --datadir=/usr/share \
                           --disable-fftw \
                           --disable-sndfile"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
