# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-freetype"
PKG_VERSION="$(get_pkg_version freetype)"
PKG_NEED_UNPACK="$(get_pkg_directory freetype)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://freetype.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib lib32-libpng"
PKG_PATCH_DIRS+=" $(get_pkg_directory freetype)/patches"
PKG_LONGDESC="The FreeType engine is a free and portable TrueType font rendering engine."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

# package specific configure options
PKG_CONFIGURE_OPTS_TARGET="LIBPNG_CFLAGS=-I${LIB32_SYSROOT_PREFIX}/usr/include \
                           LIBPNG_LDFLAGS=-L${LIB32_SYSROOT_PREFIX}/usr/lib \
                           --with-zlib"

unpack() {
  ${SCRIPTS}/get freetype
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/freetype/freetype-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_target() {
  # unset LIBTOOL because freetype uses its own
    ( cd ..
      unset LIBTOOL
      sh autogen.sh
    )
}

post_makeinstall_target() {
  sed -e "s#prefix=/usr#prefix=${SYSROOT_PREFIX}/usr#" -i "${SYSROOT_PREFIX}/usr/lib/pkgconfig/freetype2.pc"
  cp -P "${PKG_BUILD}/.${TARGET_NAME}/freetype-config" "${SYSROOT_PREFIX}/usr/bin"
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
