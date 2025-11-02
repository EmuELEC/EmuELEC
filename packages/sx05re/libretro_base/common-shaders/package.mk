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

PKG_NAME="common-shaders"
PKG_VERSION="43eaf9b91857eb8515310c74ae750895d77b20f8"
PKG_SHA256="4bc1bc61604e91fe314cf781d05b3b99e1991e65a6adafcb8464e633e156a58e"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/RetroPie/common-shaders"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="emuelec"
PKG_SHORTDESC="Manually converted libretro/common-shaders for arm devices treebranch pi"
PKG_LONGDESC="Manually converted libretro/common-shaders for arm devices treebranch pi"
PKG_GIT_CLONE_BRANCH="rpi"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"



make_target() {
  : not
}

makeinstall_target() {
  #make install INSTALLDIR="${INSTALL}/usr/share/common-shaders/pi"

mkdir -p ${INSTALL}/usr/share/common-shaders/rpi
    cp -rf ${PKG_BUILD}/* ${INSTALL}/usr/share/common-shaders/rpi
}

