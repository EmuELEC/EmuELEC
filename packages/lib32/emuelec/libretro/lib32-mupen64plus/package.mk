# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-mupen64plus"
PKG_VERSION="$(get_pkg_version mupen64plus)"
PKG_NEED_UNPACK="$(get_pkg_directory mupen64plus)"
PKG_ARCH="aarch64"
PKG_REV="1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain nasm:host lib32-${OPENGLES}"
PKG_PATCH_DIRS+=" $(get_pkg_directory mupen64plus)/patches"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32 -lto"

if [ "${PROJECT}" = "Amlogic-ce" ]; then
  PKG_MAKE_OPTS_TARGET="platform=odroid BOARD=c2"
elif [[ "${DEVICE}" =~ ^(OdroidGoAdvance|GameForce|RK356x|OdroidM1)$ ]]; then
  PKG_MAKE_OPTS_TARGET="platform=unix GLES=1 FORCE_GLES=1 HAVE_NEON=1 WITH_DYNAREC=arm"
fi

unpack() {
  ${SCRIPTS}/get mupen64plus
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/mupen64plus/mupen64plus-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

pre_configure_target() {
  CFLAGS+="-DLINUX -DEGL_API_FB -fcommon"
  CPPFLAGS+="-DLINUX -DEGL_API_FB"
  
  sed -i "s|BOARD :=.*|BOARD = N2|g" Makefile
  sed -i "s|odroid64|emuelec64|g" Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mupen64plus_libretro.so ${INSTALL}/usr/lib/libretro/mupen64plus_32b_libretro.so
}
