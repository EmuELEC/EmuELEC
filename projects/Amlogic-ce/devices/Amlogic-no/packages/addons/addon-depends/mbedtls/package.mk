# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="mbedtls"
PKG_VERSION="3.6.3.1"
PKG_SHA256="243ed496d5f88a5b3791021be2800aac821b9a4cc16e7134aa413c58b4c20e0c"
PKG_LICENSE="Apache 2.0"
PKG_SITE="https://github.com/Mbed-TLS/mbedtls"
PKG_URL="https://github.com/Mbed-TLS/mbedtls/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain jsonschema:host Jinja2:host"
PKG_DEPENDS_UNPACK="mbedtls-framework"
PKG_LONGDESC="Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols."

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
                       -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
                       -DENABLE_TESTING=OFF \
                       -DLINK_WITH_PTHREAD=ON \
                       -DENABLE_PROGRAMS=OFF \
                       -Wno-dev"

post_unpack() {
  cp -r $(get_build_dir mbedtls-framework)/* ${PKG_BUILD}/framework
}
