# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="zstd"
PKG_VERSION="1.5.2"
PKG_SHA256="3ea06164971edec7caa2045a1932d757c1815858e4c2b68c7ef812647535c23f"
PKG_LICENSE="BSD/GPLv2"
PKG_SITE="http://www.zstd.net"
PKG_URL="https://github.com/facebook/zstd/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.zst"
PKG_DEPENDS_HOST="cmake:host make:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fast real-time compression algorithm."
# Override toolchain as meson and ninja are not built yet
# and zstd is a dependency of ccache
PKG_TOOLCHAIN="cmake-make"
PKG_BUILD_FLAGS="+local-cc"

configure_package() {
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/build/cmake/CMakeLists.txt"
}

configure_host() {
  # custom cmake build to override the LOCAL_CC/CXX
  cp ${CMAKE_CONF} cmake-zstd.conf

  echo "SET(CMAKE_C_COMPILER   $CC)"  >> cmake-zstd.conf
  echo "SET(CMAKE_CXX_COMPILER $CXX)" >> cmake-zstd.conf

  cmake -DCMAKE_TOOLCHAIN_FILE=cmake-zstd.conf \
        -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN} \
        -DZSTD_LEGACY_SUPPORT=0 \
        -DZSTD_BUILD_PROGRAMS=OFF \
        -DZSTD_BUILD_TESTS=OFF \
        ${PKG_CMAKE_SCRIPT%/*}
}
