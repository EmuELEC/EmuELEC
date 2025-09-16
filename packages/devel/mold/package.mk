# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mold"
PKG_VERSION="1.10.1"
PKG_SHA256="19e4aa16b249b7e6d2e0897aa1843a048a0780f5c76d8d7e643ab3a4be1e4787"
PKG_LICENSE="AGPL-3.0-or-later"
PKG_SITE="https://github.com/rui314/mold"
PKG_URL="https://github.com/rui314/mold/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cmake:host zlib:host zstd:host openssl:host tbb:host mimalloc:host"
PKG_LONGDESC="mold is a faster drop-in replacement for existing Unix linkers"

PKG_CMAKE_OPTS_HOST="-DCMAKE_INSTALL_LIBDIR="${TOOLCHAIN}/${TARGET_NAME}/lib"
                     -DCMAKE_INSTALL_BINDIR="${TARGET_NAME}/bin" \
                     -DCMAKE_INSTALL_LIBEXECDIR="${TARGET_NAME}" \
                     -DMOLD_LTO=ON \
                     -DMOLD_MOSTLY_STATIC=ON \
                     -DMOLD_USE_SYSTEM_MIMALLOC=ON \
                     -DMOLD_USE_SYSTEM_TBB=ON"

post_makeinstall_host() {
  ln -sf ${TOOLCHAIN}/${TARGET_NAME}/bin/mold ${TARGET_PREFIX}ld.mold
}
