# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libopenmpt"
PKG_VERSION="0.6.6"
PKG_SHA256="6ddb9e26a430620944891796fefb1bbb38bd9148f6cfc558810c0d3f269876c7"
PKG_LICENSE="BSD"
PKG_SITE="https://lib.openmpt.org/libopenmpt/"
PKG_URL="https://lib.openmpt.org/files/libopenmpt/src/${PKG_NAME}-${PKG_VERSION}+release.autotools.tar.gz"
PKG_DEPENDS_TARGET="toolchain libogg libvorbis zlib"
PKG_LONGDESC="libopenmpt renders mod music files as raw audio data, for playing or conversion."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --without-mpg123 \
                           --with-vorbis \
                           --with-vorbisfile \
                           --without-pulseaudio \
                           --without-portaudio \
                           --without-portaudiocpp \
                           --without-sdl \
                           --without-sdl2 \
                           --without-sndfile \
                           --without-flac"
