# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ccache"
PKG_VERSION="4.7.4"
PKG_SHA256="df0c64d15d3efaf0b4f6837dd6b1467e40eeaaa807db25ce79c3a08a46a84e36"
PKG_LICENSE="GPL"
PKG_SITE="https://ccache.dev/download.html"
PKG_URL="https://github.com/ccache/ccache/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="cmake:host make:host zstd:host"
PKG_LONGDESC="A compiler cache to speed up re-compilation of C/C++ code by caching."
# Override toolchain as ninja is not built yet
PKG_TOOLCHAIN="cmake-make"
PKG_BUILD_FLAGS="+local-cc"

configure_host() {
  # custom cmake build to override the LOCAL_CC/CXX
  cp ${CMAKE_CONF} cmake-ccache.conf

  echo "SET(CMAKE_C_COMPILER   $CC)"  >> cmake-ccache.conf
  echo "SET(CMAKE_CXX_COMPILER $CXX)" >> cmake-ccache.conf

  cmake -DCMAKE_TOOLCHAIN_FILE=cmake-ccache.conf \
        -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN} \
        -DENABLE_DOCUMENTATION=OFF \
        -DREDIS_STORAGE_BACKEND=OFF \
        -DZSTD_FROM_INTERNET=OFF \
        -DENABLE_TESTING=OFF \
        ..
}

post_makeinstall_host() {
# setup ccache
  if [ -z "${CCACHE_DISABLE}" ]; then
    CCACHE_DIR="${BUILD_CCACHE_DIR}" ${TOOLCHAIN}/bin/ccache --max-size=${CCACHE_CACHE_SIZE}
    CCACHE_DIR="${BUILD_CCACHE_DIR}" ${TOOLCHAIN}/bin/ccache --set-config compression_level=${CCACHE_COMPRESSLEVEL}
  fi

  cat > ${TOOLCHAIN}/bin/host-gcc <<EOF
#!/bin/sh
${TOOLCHAIN}/bin/ccache ${LOCAL_CC} "\$@"
EOF

  chmod +x ${TOOLCHAIN}/bin/host-gcc

  cat > ${TOOLCHAIN}/bin/host-g++ <<EOF
#!/bin/sh
${TOOLCHAIN}/bin/ccache ${LOCAL_CXX} "\$@"
EOF

  chmod +x ${TOOLCHAIN}/bin/host-g++
}
