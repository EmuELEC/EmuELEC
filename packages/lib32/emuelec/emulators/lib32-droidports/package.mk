# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-droidports"
PKG_VERSION="$(get_pkg_version droidports)"
PKG_NEED_UNPACK="$(get_pkg_directory droidports)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/JohnnyonFlame/droidports"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-SDL2 lib32-SDL2_image lib32-openal-soft lib32-bzip2 lib32-libzip lib32-libpng"
PKG_PATCH_DIRS+=" $(get_pkg_directory droidports)/patches" 
PKG_LONGDESC="A repository for experimenting with elf loading and in-place patching of android native libraries on non-android operating systems."
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="lib32"

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release -DPLATFORM=linux -DPORT=gmloader -DUSE_BUILTIN_FREETYPE=ON"

unpack() {
  ${SCRIPTS}/get droidports
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/droidports/droidports-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/gmloader ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/gmloader
  cp $(get_pkg_directory droidports)/config/* ${INSTALL}/usr/config/emuelec/configs/gmloader
  cp $(get_pkg_directory droidports)/scripts/* ${INSTALL}/usr/bin
}
