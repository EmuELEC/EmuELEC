# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mumudvb"
PKG_VERSION="efc815ccecf5a2b9603027c959a4966fe501f6a5" # 2021-01-06
PKG_SHA256="b3a6f4a5d2f08d31afa46504dc53644ae21d7dbfa320a216efafcf1e7c44cdba"
PKG_LICENSE="GPL"
PKG_SITE="http://mumudvb.net/"
PKG_URL="https://github.com/braice/MuMuDVB/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdvbcsa"
PKG_LONGDESC="MuMuDVB (Multi Multicast DVB) is a program that streams from DVB on a network using multicasting or unicast"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"
