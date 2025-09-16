# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2022 Team CoreELEC (https://coreelec.org)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-zstd"
PKG_VERSION="$(get_pkg_version zstd)"
PKG_NEED_UNPACK="$(get_pkg_directory zstd)"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD/GPLv2"
PKG_SITE="http://www.zstd.net"
PKG_URL=""
PKG_PATCH_DIRS+=" $(get_pkg_directory zstd)/patches"
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_LONGDESC="A fast real-time compression algorithm."
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="lib32"

configure_package() {
  PKG_MESON_SCRIPT="${PKG_BUILD}/build/meson/meson.build"
}

unpack() {
  ${SCRIPTS}/get zstd
  mkdir -p ${PKG_BUILD}
  tar -I zstd --strip-components=1 -xf ${SOURCES}/zstd/zstd-${PKG_VERSION}.tar.zst -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
