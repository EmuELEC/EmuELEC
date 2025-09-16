# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libfastjson"
PKG_VERSION="1.2304.0"
PKG_SHA256="ef30d1e57a18ec770f90056aaac77300270c6203bbe476f4181cc83a2d5dc80c"
PKG_LICENSE="GPL"
PKG_SITE="https://www.rsyslog.com/tag/libfastjson"
PKG_URL="https://download.rsyslog.com/libfastjson/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fast json library for C."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes"
