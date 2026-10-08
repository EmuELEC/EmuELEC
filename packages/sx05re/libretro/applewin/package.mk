# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present EmuELEC (https://github.com/emuelec)

PKG_NAME="applewin"
PKG_VERSION="7062ae417896da6050e2e39030215062bb4672ee"
PKG_ARCH="any"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/audetto/AppleWin"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain xxd:host"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="AppleWin libretro core (Apple II/II+/IIe)"
PKG_LONGDESC="Linux port of AppleWin, an Apple II emulator, built as libretro core"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_LIBRETRO=ON \
                       -DENABLE_NETWORKING=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/source/frontends/libretro/applewin_libretro.so ${INSTALL}/usr/lib/libretro/
}
