# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2017 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="heimdal"
PKG_VERSION="f4faaeaba371fff3f8d1bc14389f5e6d70ca8e17"
PKG_SHA256="2576c5e2d793db53c86e108fd117b278437bb02d6c6db2bec4d1b86958f1980a"
PKG_LICENSE="BSD-3c"
PKG_SITE="http://www.h5l.org/"
PKG_URL="https://github.com/heimdal/heimdal/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host Python3:host ncurses:host asn1c:host"
PKG_LONGDESC="Kerberos 5, PKIX, CMS, GSS-API, SPNEGO, NTLM, Digest-MD5 and, SASL implementation."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-parallel"

PKG_CONFIGURE_OPTS_HOST="ac_cv_prog_COMPILE_ET=no \
                         --enable-static --disable-shared \
                         --without-openldap \
                         --without-capng \
                         --without-sqlite3 \
                         --without-libintl \
                         --without-openssl \
                         --without-berkeley-db \
                         --without-readline \
                         --without-libedit \
                         --without-hesiod \
                         --without-x \
                         --disable-otp \
                         --disable-heimdal-documentation"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -PR lib/asn1/asn1_compile ${TOOLCHAIN}/bin/heimdal_asn1_compile
    cp -PR lib/com_err/compile_et ${TOOLCHAIN}/bin/heimdal_compile_et
}
