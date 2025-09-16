# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="corefonts"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="http://www.openelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_LONGDESC="corefonts is a Metapackage for installing fonts"

if [ -n "${CUSTOM_FONTS}" ]; then
  PKG_DEPENDS_TARGET+=" ${CUSTOM_FONTS}"
else
  PKG_DEPENDS_TARGET+=" liberation-fonts-ttf"
fi
