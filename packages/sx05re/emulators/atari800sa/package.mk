# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="atari800sa"
PKG_VERSION="f6ae37402882d6ba39c7a242b1a1dd9eb3dac968"
PKG_SHA256="b4f7f19955dc30f8c6b0f2094edb9d8dab6f2010b811301123947222b31976b1"
PKG_SITE="https://github.com/atari800/atari800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Atari 8-bit computer and 5200 console emulator"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
  ${PKG_BUILD}/autogen.sh
}
