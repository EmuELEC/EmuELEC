# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="pkg-config"
PKG_VERSION="0.29.2"
PKG_SHA256="6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"
PKG_LICENSE="GPL"
PKG_SITE="http://www.freedesktop.org/software/pkgconfig/"
PKG_URL="http://pkg-config.freedesktop.org/releases/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="gettext:host"
PKG_LONGDESC="A system for managing library compile/link flags that works with automake and autoconf."
PKG_BUILD_FLAGS="+local-cc"

PKG_CONFIGURE_OPTS_HOST="--disable-silent-rules \
                         --with-internal-glib --disable-dtrace \
                         --with-gnu-ld"

post_makeinstall_host() {
  mkdir -p ${SYSROOT_PREFIX}/usr/share/aclocal
    cp pkg.m4 ${SYSROOT_PREFIX}/usr/share/aclocal
}
