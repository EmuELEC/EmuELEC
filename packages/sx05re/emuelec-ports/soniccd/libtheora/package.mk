# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="libtheora"
PKG_VERSION="1.1.1"
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="http://downloads.xiph.org/releases/theora"
PKG_URL="${PKG_SITE}/libtheora-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libogg libvorbis"
PKG_SHORTDESC="Theora is a free and open video compression format from the Xiph.org Foundation."
PKG_TOOLCHAIN="auto"

pre_configure_target() {
PKG_CONFIGURE_OPTS_TARGET="--disable-oggtest \
	--disable-vorbistest \
	--disable-sdltest \
	--disable-examples \
	--disable-spec"
}

