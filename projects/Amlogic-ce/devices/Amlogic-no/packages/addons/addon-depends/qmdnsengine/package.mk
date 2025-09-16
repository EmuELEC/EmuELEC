# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qmdnsengine"
PKG_VERSION="0ca80117e853671d909b3cec9e2bdcac85a13b9f"
PKG_SHA256="3ae288458e3fc1c1e636869aaca0fd5c77bdd6aec6fd4d62217d0f46acd4042c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nitroshare/qmdnsengine"
PKG_URL="https://github.com/nitroshare/qmdnsengine/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain qt-everywhere"
PKG_LONGDESC="Library provides an implementation of multicast DNS as per RFC 6762."

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF"
