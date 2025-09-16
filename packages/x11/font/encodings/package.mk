# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="encodings"
PKG_VERSION="1.0.6"
PKG_SHA256="77e301de661f35a622b18f60b555a7e7d8c4d5f43ed41410e830d5ac9084fc26"
PKG_LICENSE="OSS"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/font/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain util-macros font-util:host"
PKG_LONGDESC="X font encoding meta files."

PKG_CONFIGURE_OPTS_TARGET="--enable-gzip-small-encodings \
                           --enable-gzip-large-encodings \
                           --with-fontrootdir=/usr/share/fonts"
