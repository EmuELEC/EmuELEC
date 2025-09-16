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

PKG_NAME="handy"
PKG_VERSION="4e9e072796e5552a9d57f6ab83b3f85f27b17fb6"
PKG_SHA256="7c21fe578d1ba4271ee07530552b3cfb7deb905147edc3fb7d8c33cf5f45ec4c"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/libretro/libretro-handy"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="K. Wilkins' Atari Lynx emulator Handy for libretro"
PKG_LONGDESC="Handy is an Atari Lynx Emulator for Windows 95/98/NT/2000. Handy was the original name of the Lynx project that was started at Epyx and then finished by Atari."
PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

if [ ${ARCH} = "aarch64" ]; then
  PKG_MAKE_OPTS_TARGET=" platform=emuelec"
else
  PKG_MAKE_OPTS_TARGET=" platform=classic_armv8_a35"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp handy_libretro.so ${INSTALL}/usr/lib/libretro/
}
