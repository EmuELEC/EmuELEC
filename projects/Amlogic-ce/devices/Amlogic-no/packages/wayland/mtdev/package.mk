# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="mtdev"
PKG_VERSION="1.1.7"
PKG_SHA256="a107adad2101fecac54ac7f9f0e0a0dd155d954193da55c2340c97f2ff1d814e"
PKG_LICENSE="MIT"
PKG_SITE="http://bitmath.org"
PKG_URL="http://bitmath.org/code/mtdev/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The mtdev is a stand-alone library which transforms all variants of kernel MT events to the slotted type B protocol."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
