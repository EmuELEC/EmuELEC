# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxcvt"
PKG_VERSION="0.1.2"
PKG_SHA256="0561690544796e25cfbd71806ba1b0d797ffe464e9796411123e79450f71db38"
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/xorg/lib/libxcvt"
PKG_URL="https://www.x.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libxcvt is a library providing a standalone version of the X server implementation of the VESA CVT standard timing modelines generator."
PKG_BUILD_FLAGS="+pic"
