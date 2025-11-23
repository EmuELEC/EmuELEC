# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="fcft"
PKG_VERSION="3.3.2"
PKG_SHA256="79e52aaafc0b57fa2b68ed6127de13e98318050399a939691b8ca30d44d48591"
PKG_LICENSE="MIT"
PKG_SITE="https://codeberg.org/dnkl/fcft"
PKG_URL="https://codeberg.org/dnkl/fcft/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain pixman fontconfig freetype tllist"
PKG_LONGDESC="A simple library for font loading and glyph rasterization using FontConfig, FreeType and pixman."

PKG_MESON_OPTS_TARGET="-Ddocs=disabled \
                       -Dgrapheme-shaping=disabled \
                       -Drun-shaping=disabled \
                       -Dtest-text-shaping=false \
                       -Dexamples=false"
