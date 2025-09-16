# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-librga"
PKG_VERSION="$(get_pkg_version librga)"
PKG_NEED_UNPACK="$(get_pkg_directory librga)"
PKG_ARCH="aarch64"
PKG_LICENSE="GNU"
PKG_SITE="https://github.com/shantigilbert/linux-rga"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libdrm"
PKG_PATCH_DIRS+=" $(get_pkg_directory librga)/patches"
PKG_LONGDESC="The RGA driver userspace"
PKG_TOOLCHAIN="auto"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get librga
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/librga/librga-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
