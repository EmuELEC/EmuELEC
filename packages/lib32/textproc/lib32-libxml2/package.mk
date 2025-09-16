# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libxml2"
PKG_VERSION="$(get_pkg_version libxml2)"
PKG_NEED_UNPACK="$(get_pkg_directory libxml2)"
PKG_ARCH="aarch64"
PKG_LICENSE="MIT"
PKG_SITE="http://xmlsoft.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib"
PKG_PATCH_DIRS+=" $(get_pkg_directory libxml2)/patches"
PKG_LONGDESC="The libxml package contains an XML library, which allows you to manipulate XML files."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_header_ansidecl_h=no \
                           --enable-static \
                           --enable-shared \
                           --disable-silent-rules \
                           --enable-ipv6 \
                            --without-lzma \
                           --with-zlib=${LIB32_SYSROOT_PREFIX}/usr \
                           --without-python \
                           --with-sysroot=${LIB32_SYSROOT_PREFIX}"

unpack() {
  ${SCRIPTS}/get libxml2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libxml2/libxml2-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}

post_makeinstall_target() {
  sed -e "s:\(['= ]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/xml2-config

  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
