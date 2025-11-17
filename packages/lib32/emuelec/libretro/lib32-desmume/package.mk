# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-desmume"
PKG_VERSION="$(get_pkg_version desmume)"
PKG_NEED_UNPACK="$(get_pkg_directory desmume)"
PKG_ARCH="aarch64"
PKG_REV="1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/desmume"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib lib32-libpcap"
PKG_PATCH_DIRS+=" $(get_pkg_directory desmume)/patches"
PKG_SHORTDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32 +speed -gold"

unpack() {
  ${SCRIPTS}/get desmume
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/desmume/desmume-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

make_target() {
  cd ${PKG_BUILD}/desmume/src/frontend/libretro
	make CC=${CC} platform=classic_armv7_a7
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/desmume/src/frontend/libretro/desmume_libretro.so ${INSTALL}/usr/lib/libretro/desmume_32b_libretro.so
}
