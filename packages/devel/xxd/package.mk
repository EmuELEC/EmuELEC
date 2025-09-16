# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xxd"
PKG_VERSION="$(get_pkg_version vim)"
PKG_LICENSE="VIM"
PKG_URL=""
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_UNPACK+=" vim"
PKG_LONGDESC="make a hexdump or do the reverse"
PKG_BUILD_FLAGS="-sysroot"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/vim/vim-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

make_host() {
  ${HOST_CXX} -x c -std=c11 -O3 -Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion ../src/xxd/xxd.c -o xxd
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp -p xxd ${TOOLCHAIN}/bin
}
