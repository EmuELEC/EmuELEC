# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libvorbis"
PKG_VERSION="$(get_pkg_version libvorbis)"
PKG_NEED_UNPACK="$(get_pkg_directory libvorbis)"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD"
PKG_SITE="http://www.vorbis.com/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libogg"
PKG_PATCH_DIRS+=" $(get_pkg_directory libvorbis)/patches"
PKG_LONGDESC="Lossless audio compression tools using the ogg-vorbis algorithms."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="lib32 +pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-shared \
                           --disable-static \
                           --with-ogg=${LIB32_SYSROOT_PREFIX}/usr \
                           --disable-docs \
                           --disable-examples \
                           --disable-oggtest"

unpack() {
  ${SCRIPTS}/get libvorbis
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libvorbis/libvorbis-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
