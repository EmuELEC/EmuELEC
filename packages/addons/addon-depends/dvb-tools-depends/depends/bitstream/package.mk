# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bitstream"
PKG_VERSION="1.5"
PKG_SHA256="45fc5a5a6e4537a69fa8440821e87b76252135180a3070c631b0b36ce0a3b90a"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org"
PKG_URL="http://download.videolan.org/pub/videolan/bitstream/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="biTStream is a set of C headers allowing a simpler access to binary structures such as specified by MPEG, DVB, IETF."

PKG_MAKEINSTALL_OPTS_TARGET="PREFIX=/usr"
