# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_net"
PKG_VERSION="2.0.1"
PKG_SHA256="15ce8a7e5a23dafe8177c8df6e6c79b6749a03fff1e8196742d3571657609d21"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/projects/SDL_net/"
PKG_URL="https://www.libsdl.org/projects/SDL_net/release/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="SDL2_net: network library" 
PKG_DEPENDS_HOST="SDL2:host toolchain:host"
