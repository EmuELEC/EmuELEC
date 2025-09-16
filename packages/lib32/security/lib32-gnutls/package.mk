# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-gnutls"
PKG_VERSION="$(get_pkg_version gnutls)"
PKG_NEED_UNPACK="$(get_pkg_directory gnutls)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL2.1"
PKG_SITE="https://gnutls.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libidn2 lib32-nettle lib32-zlib"
PKG_PATCH_DIRS+=" $(get_pkg_directory gnutls)/patches"
PKG_LONGDESC="A library which provides a secure layer over a reliable transport layer."
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-doc \
                           --disable-full-test-suite \
                           --disable-guile \
                           --disable-libdane \
                           --disable-padlock \
                           --disable-rpath \
                           --disable-tests \
                           --disable-tools \
                           --disable-valgrind-tests \
                           --with-idn \
                           --with-included-libtasn1 \
                           --with-included-unistring \
                           --without-p11-kit \
                           --without-tpm"

unpack() {
  ${SCRIPTS}/get gnutls
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/gnutls/gnutls-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
