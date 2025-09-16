# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pigz"
PKG_VERSION="2.7"
PKG_SHA256="d2045087dae5e9482158f1f1c0f21c7d3de6f7cdc7cc5848bdabda544e69aa58"
PKG_LICENSE="Other"
PKG_SITE="https://zlib.net/pigz/"
PKG_URL="https://github.com/madler/pigz/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="make:host zlib:host"
PKG_LONGDESC="a parallel implementation of the gzip file compressor"
PKG_TOOLCHAIN="manual"

make_host() {
  make CPPFLAGS="${CPPFLAGS} -I${TOOLCHAIN}/include" \
       LDFLAGS="${LDFLAGS}" \
       CXX="${CXX}" \
       CC="${CC}" \
       pigz
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp pigz ${TOOLCHAIN}/bin
}
