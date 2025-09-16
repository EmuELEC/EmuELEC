# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="comskip"
PKG_VERSION="84fcd7388394c95fc8a7e558642bbadb43134507"
PKG_SHA256="4d45d30335ce1c28fb4de8865ada57f81de18d83a77950e9ab7c3ea26d24a883"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kaashoek.com/comskip/"
PKG_URL="https://github.com/erikkaashoek/Comskip/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain argtable2 ffmpegx"
PKG_DEPENDS_CONFIG="argtable2 ffmpegx"
PKG_LONGDESC="Comskip detects commercial breaks from a video stream. It can be used for post-processing recordings."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

pre_configure_target() {
  # pass ffmpegx to build
  CFLAGS+=" -I$(get_install_dir ffmpegx)/usr/local/include"
  LDFLAGS+=" -L$(get_install_dir ffmpegx)/usr/local/lib -ldl"
}
