# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="argtable2"
PKG_VERSION="2.13"
PKG_SHA256="8f77e8a7ced5301af6e22f47302fdbc3b1ff41f2b83c43c77ae5ca041771ddbf"
PKG_LICENSE="BSD"
PKG_SITE="http://argtable.sourceforge.net/"
PKG_URL="https://downloads.sourceforge.net/project/argtable/argtable/argtable-${PKG_VERSION}/argtable2-${PKG_VERSION:2:4}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Argtable is an open source ANSI C library that parses GNU-style command-line options."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
