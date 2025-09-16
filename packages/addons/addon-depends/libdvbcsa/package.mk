# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libdvbcsa"
PKG_VERSION="2a1e61e569a621c55c2426f235f42c2398b7f18f" # 2018-01-29
PKG_SHA256="0cca50576222475afd6945fc883ee19870656a73353eb0b219078671abaf3fbb"
PKG_LICENSE="LGPL"
PKG_SITE="https://www.videolan.org/developers/libdvbcsa.html"
PKG_URL="https://github.com/glenvt18/libdvbcsa/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A implementation of DVB/CSA, with encryption and decryption capabilities."
PKG_TOOLCHAIN="autotools"
# libdvbcsa is a bit faster without LTO, and tests will fail with gcc-5.x
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared --enable-static --with-sysroot=${SYSROOT_PREFIX}"

if target_has_feature neon; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
elif [ "${TARGET_ARCH}" = x86_64  ]; then
  if target_has_feature ssse3; then
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-ssse3"
  elif target_has_feature sse2; then
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-sse2"
  else
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-uint64"
  fi
fi
