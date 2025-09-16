# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="potator"
PKG_VERSION="735bc376974be564045356188a3b899f2b6fedbd"
PKG_SHA256="ead7e667ca71f3cf79b9ddde4476765d00580ad5780868f36348062f062ea083"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="The Unlicense"
PKG_SITE="https://github.com/libretro/potator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_LONGDESC="A Watara Supervision Emulator based on Normmatt version "
PKG_TOOLCHAIN="make"

make_target() {
cd ${PKG_BUILD}/platform/libretro
make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/platform/libretro/potator_libretro.so ${INSTALL}/usr/lib/libretro/potator_libretro.so
}
