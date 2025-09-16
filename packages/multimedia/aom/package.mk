# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aom"
PKG_VERSION="3.5.0"
PKG_SHA256="d37dbee372e2430a7efde813984ae6d78bdf1fc4080ebe32457c9115408b0738"
PKG_LICENSE="BSD"
PKG_SITE="https://www.webmproject.org"
PKG_URL="https://storage.googleapis.com/aom-releases/libaom-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="AV1 Codec Library"
PKG_BUILD_FLAGS="+pic"

PKG_CMAKE_OPTS_TARGET="-DENABLE_CCACHE=1 \
                       -DENABLE_DOCS=0 \
                       -DENABLE_EXAMPLES=0 \
                       -DENABLE_TESTS=0 \
                       -DENABLE_TOOLS=0"

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" nasm:host"
elif ! target_has_feature neon; then
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_NEON=0 -DENABLE_NEON_ASM=0"
fi
