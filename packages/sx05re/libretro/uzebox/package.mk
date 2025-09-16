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

PKG_NAME="uzebox"
PKG_VERSION="e5faef9a287cc98ac9fae2ce99a0117c37be460a"
PKG_SHA256="e7fcee86e35b96aec94234b19e2e514d83a82a1342a84af0a93e5e18810ddb93"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/t-paul/uzebox"
PKG_URL="https://github.com/t-paul/uzebox/archive/${PKG_VERSION}.tar.gz"
PKG_PATCH_DIRS="libretro"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="A retro-minimalist game console engine for the ATMega644"
PKG_LONGDESC="A retro-minimalist game console engine for the ATMega644"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make -C tools/uzem CPPFLAGS="${CFLAGS} -I. ${LDFLAGS} -DNOGDB=1" CC="${CXX}" LIBRETRO_BUILD=1
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp tools/uzem/uzem_libretro.so ${INSTALL}/usr/lib/libretro/
}
