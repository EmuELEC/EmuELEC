# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libestr"
PKG_VERSION="0.1.11"
PKG_SHA256="46b53b80f875fd82981d927a45f0c9df9d17ee1d0e29efab76aaa9cd54a46bb4"
PKG_LICENSE="GPL"
PKG_SITE="http://libestr.adiscon.com"
PKG_URL="https://github.com/rsyslog/libestr/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="autotools"
PKG_LONGDESC="Some essentials for string handling."

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes"
