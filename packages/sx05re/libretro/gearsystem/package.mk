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

PKG_NAME="gearsystem"
PKG_VERSION="c1592d77ee3ab7f2ae7f4ae78a62b9d17cd75cbb"
PKG_SHA256="b930097d9efee54f8dd1d6c9151be3f6efb134b0ac3abc0d554ea7ede4f01bb4"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/drhelius/Gearsystem"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Gearsystem is a Sega Master System / Game Gear / SG-1000 emulator written in C++"
PKG_LONGDESC="Gearsystem is a Sega Master System / Game Gear / SG-1000 emulator written in C++"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  make -C platforms/libretro/
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp platforms/libretro/gearsystem_libretro.so ${INSTALL}/usr/lib/libretro/
}
