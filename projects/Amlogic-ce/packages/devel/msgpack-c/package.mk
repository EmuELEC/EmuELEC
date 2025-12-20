# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="msgpack-c"
PKG_VERSION="c3df1bb26ebdd01d618ecca7ae2d6b4e37d5abd7"
PKG_SHA256="581442dd9b94de53b75eb3de3cc0bb96c52e6690125223ecf4fff407772d3949"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/msgpack/msgpack-c"
PKG_URL="https://github.com/msgpack/msgpack-c/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Its like JSON but fast and small."

PKG_CMAKE_OPTS_TARGET="-DMSGPACK_ENABLE_SHARED=OFF \
                       -DMSGPACK_ENABLE_STATIC=ON"
