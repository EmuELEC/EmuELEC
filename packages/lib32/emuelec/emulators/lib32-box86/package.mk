# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-box86"
PKG_VERSION="$(get_pkg_version box86)"
PKG_NEED_UNPACK="$(get_pkg_directory box86)"
PKG_ARCH="aarch64"
PKG_REV="1"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box86"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-gl4es"
PKG_PATCH_DIRS+=" $(get_pkg_directory box86)/patches"
PKG_LONGDESC="Box86 - Linux Userspace x86 Emulator with a twist, targeted at ARM Linux devices"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="lib32"

if [ "${PROJECT}" = "Amlogic-ce" ]; then
  if [ "${DEVICE}" = "Amlogic-old" ]; then
    PKG_PATCH_DIRS+=" ${PROJECT_DIR}/Amlogic-ce/devices/Amlogic-old/patches/box86"
  fi
  PKG_CMAKE_OPTS_TARGET=" -DRK3399=ON -DCMAKE_BUILD_TYPE=Release"
else
  PKG_CMAKE_OPTS_TARGET=" -DGOA_CLONE=ON -DCMAKE_BUILD_TYPE=Release"
fi

unpack() {
  ${SCRIPTS}/get box86
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/box86/box86-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/emuelec/bin/box86/lib
  cp ${PKG_BUILD}/x86lib/* ${INSTALL}/usr/config/emuelec/bin/box86/lib
  cp ${PKG_BUILD}/.${TARGET_NAME}/box86 ${INSTALL}/usr/config/emuelec/bin/box86/
  
  mkdir -p ${INSTALL}/etc/binfmt.d
  ln -sf /emuelec/configs/box86.conf ${INSTALL}/etc/binfmt.d/box86.conf
}
