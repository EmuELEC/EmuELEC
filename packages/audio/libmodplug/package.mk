# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libmodplug"
PKG_VERSION="0.8.9.0"
PKG_SHA256="457ca5a6c179656d66c01505c0d95fafaead4329b9dbaa0f997d00a3508ad9de"
PKG_LICENSE="GPL"
PKG_SITE="http://modplug-xmms.sourceforge.net/"
PKG_URL="${SOURCEFORGE_SRC}/modplug-xmms/libmodplug/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libmodplug renders mod music files as raw audio data, for playing or conversion."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
