# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_SHA256="f41379682f9ada94ea7b34fe86bf9ee00935a3147be41b6569c9605a53e438fd"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="${SOURCEFORGE_SRC}/${PKG_NAME}/FreeImage${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage"
PKG_LONGDESC="FreeImage library"

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0"
}
