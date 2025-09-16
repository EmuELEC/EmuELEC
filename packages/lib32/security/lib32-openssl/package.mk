# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-openssl"
PKG_VERSION="$(get_pkg_version openssl)"
PKG_NEED_UNPACK="$(get_pkg_directory openssl)"
PKG_ARCH="aarch64"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://www.openssl.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory openssl)/patches"
PKG_LONGDESC="The Open Source toolkit for Secure Sockets Layer and Transport Layer Security"
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --openssldir=/etc/ssl
                           --libdir=lib \
                           shared \
                           threads \
                           no-ec2m \
                           no-md2 \
                           no-rc5 \
                           no-rfc3779 \
                           no-sctp \
                           no-ssl-trace \
                           no-ssl3 \
                           no-unit-test \
                           no-weak-ssl-ciphers \
                           no-zlib \
                           no-zlib-dynamic \
                           no-static-engine \
                           linux-armv4"

unpack() {
  ${SCRIPTS}/get openssl
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/openssl/openssl-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_unpack() {
  find ${PKG_BUILD}/apps -type f | xargs -n 1 -t sed 's|./demoCA|/etc/ssl|' -i
}

pre_configure_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -a ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}/
}

configure_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  ./Configure ${PKG_CONFIGURE_OPTS_TARGET} ${CFLAGS} ${LDFLAGS}
}

makeinstall_target() {
  make DESTDIR=${INSTALL} install_sw
  make DESTDIR=${SYSROOT_PREFIX} install_sw
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
