# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="w_scan"
PKG_VERSION="20170107"
PKG_SHA256="38e0f38a7bf06cff6d6ea01652ad4ee60da2cb0e937360468f936da785b46ffe"
PKG_LICENSE="GPL"
PKG_SITE="https://www.gen2vdr.de/wirbel/w_scan/index2.html"
PKG_URL="https://www.gen2vdr.de/wirbel/w_scan/w_scan-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A channel scan tool which generates ATSC, DVB-C, DVB-S/S2 and DVB-T channels.conf files."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"
