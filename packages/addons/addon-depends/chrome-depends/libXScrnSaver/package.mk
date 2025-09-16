# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libXScrnSaver"
PKG_VERSION="1.2.4"
PKG_SHA256="75cd2859f38e207a090cac980d76bc71e9da99d48d09703584e00585abc920fe"
PKG_LICENSE="GPL"
PKG_SITE="https://xorg.freedesktop.org/"
PKG_URL="https://xorg.freedesktop.org/releases/individual/lib/libXScrnSaver-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libXext scrnsaverproto"
PKG_LONGDESC="X11 Screen Saver extension client library."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--disable-static \
                           --enable-shared \
                           --enable-malloc0returnsnull"
