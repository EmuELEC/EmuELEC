# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mpfr"
PKG_VERSION="4.2.2"
PKG_SHA256="b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.mpfr.org/"
PKG_URL="https://ftpmirror.gnu.org/mpfr/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host gmp:host"
PKG_DEPENDS_TARGET="gmp"
PKG_LONGDESC="A C library for multiple-precision floating-point computations with exact rounding."

PKG_CONFIGURE_OPTS_HOST="--target=${TARGET_NAME} \
                         --enable-static --disable-shared \
                         --prefix=${TOOLCHAIN} \
                         --with-gmp-lib=${TOOLCHAIN}/lib \
                         --with-gmp-include=${TOOLCHAIN}/include"

PKG_CONFIGURE_OPTS_TARGET="--target=${TARGET_NAME} \
                         --enable-static --disable-shared"
