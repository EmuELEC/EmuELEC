# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libsodium"
PKG_VERSION="e2bd4024008c73f1c0402e1c2f4db9a2300e9c95" # 1.0.18-stable 2022-09-24
PKG_SHA256="b5035fcc061e410291baded4098a3ab56da90eb7d47d82ba2d0e05e3d105b8f6"
PKG_LICENSE="ISC"
PKG_SITE="https://libsodium.org/"
PKG_URL="https://github.com/jedisct1/libsodium/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A modern, portable, easy to use crypto library"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared"
