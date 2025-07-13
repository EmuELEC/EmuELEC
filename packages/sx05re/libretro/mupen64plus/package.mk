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

PKG_NAME="mupen64plus"
PKG_VERSION="ab8134ac90a567581df6de4fc427dd67bfad1b17"
PKG_SHA256="98e197cdcac64c0e08eda91a6d63b637c3f151066bede25766e62bc1a59552a0"
PKG_REV="1"
PKG_ARCH="arm"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host ${OPENGLES}"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {

  CFLAGS="${CFLAGS} -DLINUX -DEGL_API_FB -fcommon"
  CPPFLAGS="${CPPFLAGS} -DLINUX -DEGL_API_FB"
  
  sed -i "s|BOARD :=.*|BOARD = N2|g" Makefile
  sed -i "s|odroid64|emuelec64|g" Makefile
  
   case ${DEVICE} in
    Amlogic-ng|Amlogic-ogu)
    if [ ${ARCH} == "arm" ]; then
		PKG_MAKE_OPTS_TARGET="platform=odroid BOARD=c2"
      else
		PKG_MAKE_OPTS_TARGET="platform=emuelec64 BOARD=N2"
      fi
    ;;
    Amlogic-old)
    if [ ${ARCH} == "arm" ]; then
		PKG_MAKE_OPTS_TARGET="platform=odroid BOARD=c2"
      else
		PKG_MAKE_OPTS_TARGET="platform=odroid64 BOARD=c2 HAVE_NEON=0"
      fi
    ;;
  esac
 
 if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ] || [ "${DEVICE}" == "RK356x" ]; then 
	if [[ "${ARCH}" == "arm" ]]; then
		PKG_MAKE_OPTS_TARGET=" platform=unix GLES=1 FORCE_GLES=1 HAVE_NEON=1 WITH_DYNAREC=arm"
	else 
		PKG_MAKE_OPTS_TARGET=" platform=unix GLES=1 FORCE_GLES=1 HAVE_NEON=0 WITH_DYNAREC=aarch64"
	fi
 fi
  
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mupen64plus_libretro.so ${INSTALL}/usr/lib/libretro/mupen64plus_32b_libretro.so
}
