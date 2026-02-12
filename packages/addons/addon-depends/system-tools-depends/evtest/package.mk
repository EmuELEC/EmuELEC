# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="evtest"
PKG_VERSION="1.35"
PKG_SHA256="06dfe6b9760b78f3f73aca2120cbcb79339b33e59d5c79a49b4bd5d34844b054"
PKG_LICENSE="GPL"
PKG_SITE="http://cgit.freedesktop.org/evtest/"
PKG_URL="https://gitlab.freedesktop.org/libevdev/evtest/-/archive/evtest-${PKG_VERSION}/evtest-evtest-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libxml2"
PKG_LONGDESC="A simple tool for input event debugging."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"
