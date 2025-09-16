# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="crossguid"
PKG_VERSION="ca1bf4b810e2d188d04cb6286f957008ee1b7681" # 2019-05-30
PKG_SHA256="6be27e0b3a4907f0cd3cfadec255ee1b925569e1bd06e67a4d2f4267299b69c4"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/graeme-hill/crossguid"
PKG_URL="https://github.com/graeme-hill/crossguid/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain util-linux"
PKG_LONGDESC="minimal, cross platform, C++ GUID library"

PKG_CMAKE_OPTS_TARGET="-DCROSSGUID_TESTS=OFF \
                       -Wno-dev"
