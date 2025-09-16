# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-flac"
PKG_VERSION="$(get_pkg_version flac)"
PKG_NEED_UNPACK="$(get_pkg_directory flac)"
PKG_LICENSE="GPLv2"
PKG_SITE="https://xiph.org/flac/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libogg"
PKG_PATCH_DIRS+=" $(get_pkg_directory flac)/patches"
PKG_LONGDESC="An Free Lossless Audio Codec."
PKG_TOOLCHAIN="autotools"
# flac-1.3.1 dont build with LTO support
PKG_BUILD_FLAGS="lib32 +pic"

# package specific configure options
PKG_CONFIGURE_OPTS_TARGET="--enable-shared \
                           --disable-static \
                           --disable-rpath \
                           --disable-altivec \
                           --disable-doxygen-docs \
                           --disable-thorough-tests \
                           --disable-cpplibs \
                           --disable-xmms-plugin \
                           --disable-oggtest \
                           --with-ogg=${LIB32_SYSROOT_PREFIX}/usr \
                           --with-gnu-ld"

if target_has_feature sse; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-sse"
else
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-sse"
fi

unpack() {
  ${SCRIPTS}/get flac
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/flac/flac-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
