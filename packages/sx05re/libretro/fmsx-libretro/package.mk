# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fmsx-libretro"
PKG_VERSION="9eb5f25df5397212a3e3088ca1a64db0740bbe5f"
PKG_SHA256="a20197dc2bf8ab01f79dc341233656053de8bd78cf8e597b6e375bf0722d2b28"
PKG_ARCH="any"
PKG_LICENSE="OPEN/NON-COMMERCIAL"
PKG_SITE="https://github.com/libretro/fmsx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Port of fMSX to the libretro API. "
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp fmsx_libretro.so ${INSTALL}/usr/lib/libretro/
}
