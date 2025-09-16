# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-pcsx_rearmed"
PKG_VERSION="$(get_pkg_version pcsx_rearmed)"
PKG_NEED_UNPACK="$(get_pkg_directory pcsx_rearmed)"
PKG_ARCH="aarch64"
PKG_REV="1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib"
PKG_PATCH_DIRS+=" $(get_pkg_directory pcsx_rearmed)/patches"
PKG_SHORTDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32 +speed -gold"

unpack() {
  ${SCRIPTS}/get pcsx_rearmed
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/pcsx_rearmed/pcsx_rearmed-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

make_target() {
  cd ${PKG_BUILD}
  export ALLOW_LIGHTREC_ON_ARM=1
  if [ "${DEVICE}" = "Amlogic-old" ]; then
    make -f Makefile.libretro GIT_VERSION=${PKG_VERSION} platform=rpi3
  else
    make -f Makefile.libretro GIT_VERSION=${PKG_VERSION} platform=rpi4
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp pcsx_rearmed_libretro.so ${INSTALL}/usr/lib/libretro/pcsx_rearmed_32b_libretro.so
}
