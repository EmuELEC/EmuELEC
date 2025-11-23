# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qmdnsengine"
PKG_VERSION="4e54bc86c8ed2d4fa2e7449d4ba6a6a2742d9eb1"
PKG_SHA256="c1d0179286274ac8d9c147adc2ff23784acd2a9e654f332e9becf2c3356eef78"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nitroshare/qmdnsengine"
PKG_URL="https://github.com/nitroshare/qmdnsengine/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain qt5"
PKG_LONGDESC="Library provides an implementation of multicast DNS as per RFC 6762."

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
