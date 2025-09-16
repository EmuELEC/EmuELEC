# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libmodplug"
PKG_VERSION="$(get_pkg_version libmodplug)"
PKG_NEED_UNPACK="$(get_pkg_directory libmodplug)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://modplug-xmms.sourceforge.net/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libmodplug)/patches"
PKG_LONGDESC="libmodplug renders mod music files as raw audio data, for playing or conversion."
PKG_BUILD_FLAGS="lib32 +pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"

unpack() {
  ${SCRIPTS}/get libmodplug
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libmodplug/libmodplug-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
