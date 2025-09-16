# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dvbsnoop"
PKG_VERSION="badf61fcdab1177c1162747be06d035a2b671e9b"
PKG_SHA256="7f0f5d9ca15c5caae3ca249d95a5fc30cececd16f63e00a1404e0d2368ce56fa"
PKG_LICENSE="GPL"
PKG_SITE="http://dvbsnoop.sourceforge.net/"
PKG_URL="https://github.com/Duckbox-Developers/dvbsnoop/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="dvbsnoop is a DVB/MPEG stream analyzer program"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"
