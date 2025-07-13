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

PKG_NAME="retroarch-assets"
#PKG_VERSION="fb39cdde6dfaea2c98218d28c71b14afc632fa03"
#PKG_SHA256="7be775fa493185d4f23725e2a550f6b8115e1f6544c56f82729469d97e13f9e5"
PKG_VERSION="818aca56efd784624a241a12936b5c0864e3ddd8"
PKG_SHA256="4ab725ff4e016b4c68ebd0de2c60e610cda67c9991b751eaac8fe54bcb9c1189"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/retroarch-assets"
PKG_URL="https://github.com/libretro/retroarch-assets/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="RetroArch assets. Background and icon themes for the menu drivers."
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  cd ../
  rm -rf .${TARGET_NAME}
}

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/retroarch-assets"
  
  
  # Remove unnecesary Retroarch Assets
  for i in Automatic branding cfg devtools FlatUX glui nxrgui pkg/wiiu scripts Systematic switch wallpapers COPYING; do
    rm -rf "${INSTALL}/usr/share/retroarch-assets/${i}"
  done
  
  for i in automatic dot-art flatui neoactive pixel retroactive retrosystem systematic convert.sh NPMApng2PMApng.py; do
  rm -rf "${INSTALL}/usr/share/retroarch-assets/xmb/${i}"
  done
  
  
  
}
