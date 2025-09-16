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

PKG_NAME="scummvm"
PKG_VERSION="8e9d265d81661dcffe0bc326e07e50af5d1d224a"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/scummvm"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="ScummVM with libretro backend."
PKG_LONGDESC="ScummVM is a program which allows you to run certain classic graphical point-and-click adventure games, provided you already have their data files."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto"

post_unpack() {
  sed -i "s|DEFINES  += -Wno-multichar|#DEFINES  += -Wno-multichar|" ${PKG_BUILD}/Makefile.common
}

make_target() {
  cd "${PKG_BUILD}/backends/platform/libretro"
  make all platform=rpi4_64
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp "${PKG_BUILD}/backends/platform/libretro/scummvm_libretro."{so,info} ${INSTALL}/usr/lib/libretro/
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/scummvm
  cp ${PKG_BUILD}/backends/platform/libretro/scummvm.zip ${INSTALL}/usr/config/emuelec/configs/scummvm
}
