# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="patch"
PKG_VERSION="2.7.6"
PKG_SHA256="ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd"
PKG_LICENSE="GPL"
PKG_SITE="http://savannah.gnu.org/projects/patch/"
PKG_URL="http://ftpmirror.gnu.org/patch/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Patch takes a patch file containing a difference listing produced by the diff."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--disable-xattr"
