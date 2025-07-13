# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="beetle-psx-hw"
PKG_VERSION="b62e2aa1b3ad2d027a06542305e12a52e5f5d4c4"
PKG_SHA256="a9a36839410c3024a289ea910fe859f1c2bc48c26dfe1d86d5a9acb0a6f148e1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/ZachCook/beetle-psx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Fork of Mednafen PSX"
PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_BRANCH="lightrec"

make_target() {
  make HAVE_HW=1
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mednafen_lynx_libretro.so ${INSTALL}/usr/lib/libretro/
}
