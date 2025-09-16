# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-retrorun"
PKG_VERSION="$(get_pkg_version retrorun)"
PKG_NEED_UNPACK="$(get_pkg_directory retrorun)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/navy1978/retrorun-go2"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libgo2 lib32-libdrm linux:host"
PKG_DEPENDS_UNPACK="linux"
PKG_PATCH_DIRS+=" $(get_pkg_directory retrorun)/patches"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32"

PKG_MAKE_OPTS_TARGET="config=release ARCH=" 

unpack() {
  ${SCRIPTS}/get retrorun
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/retrorun/retrorun-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

pre_configure_target() {
  local TARGET_KERNEL_PATCH_ARCH=aarch64
  CFLAGS+=" -I$(get_build_dir lib32-libdrm)/include/drm"
  CFLAGS+=" -I$(get_build_dir linux)/include/uapi"
  CFLAGS+=" -I$(get_build_dir linux)/tools/include"
  sed -i "s|/storage/.config/distribution/|/emuelec/|g" ${PKG_BUILD}/src/main.cpp
  safe_remove ${PKG_BUILD}/retrorun
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -va retrorun ${INSTALL}/usr/bin/retrorun32
}
