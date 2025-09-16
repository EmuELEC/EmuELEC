# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="SDL2_gfx"
PKG_VERSION="29927b386a32ffda432a7058e831b3da62e3d1f9"
PKG_SHA256="812fe76eec07c2b0b9f2cc3a9393d6b3ddb2a243d8f2c45a227da2adef532b63"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/jjYBdx4IL/SDL2_gfx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="SDL_image is an image file loading library. "
PKG_TOOLCHAIN="configure"

pre_configure_target() {
export CC=${CC}
}
PKG_CONFIGURE_OPTS_TARGET=" --disable-mmx"

