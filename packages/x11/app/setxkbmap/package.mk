# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="setxkbmap"
PKG_VERSION="1.3.3"
PKG_SHA256="b560c678da6930a0da267304fa3a41cc5df39a96a5e23d06f14984c87b6f587b"
PKG_LICENSE="OSS"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/app/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libX11 libxkbfile xrandr"
PKG_LONGDESC="Setxkbmap sets the keyboard using the X Keyboard Extension."
