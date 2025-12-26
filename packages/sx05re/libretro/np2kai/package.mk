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

PKG_NAME="np2kai"
PKG_VERSION="3ccfef9d7a4779591f72ff5ea7db13a1e7f3b137"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/NP2kai"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Neko Project II kai"
PKG_TOOLCHAIN="make"

pre_make_target() {
  # Fix 1: Remove the -municode flag using the absolute package build path
  if [ -f "${PKG_BUILD}/Makefile.libretro" ]; then
    sed -i 's/-municode//g' "${PKG_BUILD}/Makefile.libretro"
  fi

  # Fix 2: Comment out the s_window line in the correct path
  if [ -f "${PKG_BUILD}/sdl/scrnmng.c" ]; then
    sed -i 's/.*SDL_SetWindowFullscreen(s_window.*/\/\/ &/' "${PKG_BUILD}/sdl/scrnmng.c"
  fi
}

make_target() {
cd ${PKG_BUILD}/sdl
    make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/sdl/np2kai_libretro.so ${INSTALL}/usr/lib/libretro/
}
