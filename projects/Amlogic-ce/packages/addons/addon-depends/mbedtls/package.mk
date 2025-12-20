# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="mbedtls"
PKG_VERSION="3.3.0"
PKG_SHA256="113fa84bc3cf862d56e7be0a656806a5d02448215d1e22c98176b1c372345d33"
PKG_LICENSE="Apache 2.0"
PKG_SITE="https://github.com/Mbed-TLS/mbedtls"
PKG_URL="https://github.com/Mbed-TLS/mbedtls/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain jsonschema:host Jinja2:host"
PKG_LONGDESC="Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols."

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
			                 -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
			                 -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
			                 -DENABLE_TESTING=OFF \
			                 -DENABLE_PROGRAMS=OFF \
			                 -DLINK_WITH_PTHREAD=ON \
			                 -Wno-dev"
