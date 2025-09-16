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

PKG_NAME="opusfile"
PKG_VERSION="58b229a"
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/xiph/opusfile"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain openssl opus libogg"
PKG_PRIORITY="optional"
PKG_SHORTDESC="Stand-alone decoder library for .opus streams"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
  ${PKG_BUILD}/autogen.sh
}
