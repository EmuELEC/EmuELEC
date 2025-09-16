# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_image"
PKG_VERSION="2.8.2"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libjpeg-turbo libwebp"
PKG_LONGDESC="SDL_image is an image file loading library. "
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_TARGET=" -DSDL2IMAGE_WEBP=ON"
