# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="ftgl"
PKG_VERSION="2.1.2"
PKG_SHA256="0f61d978c28cd5d78daded591f5b03f71248c0a51c7965733e8729c874265f50"
PKG_LICENSE="GPL"
PKG_SITE="http://sourceforge.net/projects/ftgl/"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain freetype"
PKG_LONGDESC="a free cross-platform Open Source C++ library that uses Freetype2 to simplify rendering fonts in OpenGL applications"

PKG_CMAKE_OPTS_TARGET="-DOUTPUT_DIR=${SYSROOT_PREFIX}/usr"
