# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libspng"
PKG_VERSION="0.6.1"
PKG_SHA256="336856bea0216fe0ddc6cc584be5823cfd3a142e9d90d8e1635d2d2a5241f584"
PKG_LICENSE="BSD 2-clause 'Simplified'"
PKG_SITE="https://libspng.org/"
PKG_URL="https://github.com/randy408/libspng/archive/v$PKG_VERSION.tar.gz"
PKG_DEPENDS_HOST="zlib:host"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="libspng is a C library for reading and writing Portable Network Graphics (PNG) format files with a focus on security and ease of use."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="-DSPNG_STATIC=ON \
                     -DSPNG_SHARED=OFF"
