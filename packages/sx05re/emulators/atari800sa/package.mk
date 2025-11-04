# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="atari800sa"
PKG_VERSION="fcb6e799734c749f9e326640f4d506abf854e95c"
PKG_SHA256="e96cc007ab9115fe69f9e914813c7c3a5381885033f1ed4c35f21624bbb365c3"
PKG_SITE="https://github.com/atari800/atari800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Atari 8-bit computer and 5200 console emulator"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
  ${PKG_BUILD}/autogen.sh
}
