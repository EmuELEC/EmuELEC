################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="psp1"
PKG_VERSION="edf1cb70cc01c9f4ce81a83e1538c7b5ab7a2658"
PKG_SHA256="66e8c2902e2580c1e77cd13e2128a59fd0aac1a672782e73ba3c2a4411bdc247"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/PSP1"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Non-shallow fork of PPSSPP for libretro exclusively."
PKG_LONGDESC="A fast and portable PSP emulator"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
PKG_BUILD_FLAGS="-lto"

make_target() {
  cd ${PKG_BUILD}/libretro
  if [ "${OPENGLES}" == "gpu-viv-bin-mx6q" ]; then
    CFLAGS="${CFLAGS} -DLINUX -DEGL_API_FB"
    CXXFLAGS="${CXXFLAGS} -DLINUX -DEGL_API_FB"
  fi
  if [ "${ARCH}" == "arm" ]; then
    SYSROOT_PREFIX=${SYSROOT_PREFIX} make platform=imx6
  else
    make
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ../libretro/ppsspp_libretro.so ${INSTALL}/usr/lib/libretro/
}
