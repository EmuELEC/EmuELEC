# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-alsa-lib"
PKG_VERSION="$(get_pkg_version alsa-lib)"
PKG_NEED_UNPACK="$(get_pkg_directory alsa-lib)"
PKG_LICENSE="GPL"
PKG_SITE="https://www.alsa-project.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory alsa-lib)/patches"
PKG_LONGDESC="ALSA (Advanced Linux Sound Architecture) is the next generation Linux Sound API."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic lib32"

if build_with_debug; then
  PKG_ALSA_DEBUG=--with-debug
else
  PKG_ALSA_DEBUG=--without-debug
fi

PKG_CONFIGURE_OPTS_TARGET="${PKG_ALSA_DEBUG} \
                           --disable-dependency-tracking \
                           --with-plugindir=/usr/lib/alsa \
                           --disable-python"

unpack() {
  ${SCRIPTS}/get alsa-lib
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/alsa-lib/alsa-lib-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}


post_configure_target() {
  sed -i 's/.*PKGLIBDIR.*/#define PKGLIBDIR ""/' include/config.h
}

post_makeinstall_target() {
  # Don't need any binary
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
