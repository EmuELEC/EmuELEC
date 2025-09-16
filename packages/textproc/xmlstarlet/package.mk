# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="xmlstarlet"
PKG_VERSION="1.6.1"
PKG_SHA256="15d838c4f3375332fd95554619179b69e4ec91418a3a5296e7c631b7ed19e7ca"
PKG_LICENSE="MIT"
PKG_SITE="http://xmlstar.sourceforge.net"
PKG_URL="http://netcologne.dl.sourceforge.net/project/xmlstar/${PKG_NAME}/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="libxml2:host libxslt:host"
PKG_DEPENDS_TARGET="toolchain libxml2 libxslt"
PKG_LONGDESC="XMLStarlet is a command-line XML utility which allows the modification and validation of XML documents."

PKG_CONFIGURE_OPTS_HOST="  ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes \
                           --enable-static-libs \
                           LIBXML_CONFIG=${TOOLCHAIN}/bin/xml2-config \
                           LIBXSLT_CONFIG=${TOOLCHAIN}/bin/xslt-config \
                           --with-libxml-include-prefix=${TOOLCHAIN}/include/libxml2 \
                           --with-libxml-libs-prefix=${TOOLCHAIN}/lib \
                           --with-libxslt-include-prefix=${TOOLCHAIN}/include \
                           --with-libxslt-libs-prefix=${TOOLCHAIN}/lib"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes \
                           --enable-static-libs \
                           LIBXML_CONFIG=${SYSROOT_PREFIX}/usr/bin/xml2-config \
                           LIBXSLT_CONFIG=${SYSROOT_PREFIX}/usr/bin/xslt-config \
                           --with-libxml-include-prefix=${SYSROOT_PREFIX}/usr/include/libxml2 \
                           --with-libxml-libs-prefix=${SYSROOT_PREFIX}/usr/lib \
                           --with-libxslt-include-prefix=${SYSROOT_PREFIX}/usr/include \
                           --with-libxslt-libs-prefix=${SYSROOT_PREFIX}/usr/lib"

post_makeinstall_host() {
  ln -sf xml ${TOOLCHAIN}/bin/xmlstarlet
}

post_makeinstall_target() {
  ln -sf xml ${INSTALL}/usr/bin/xmlstarlet
}
