# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024

PKG_NAME="dice"
PKG_VERSION="f41ed433ed90716521b05437c49684c370faa9df"
#PKG_SHA256=""
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/mittonk/dice-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="DICE - Discrete Integrated Circuit Emulator"
PKG_LONGDESC="Emulates computer systems that lack any type of CPU, consisting only of discrete logic components. Supports Pong, Breakout and other early arcade games."
PKG_TOOLCHAIN="make"

PKG_LIBNAME="dice_libretro.so"
PKG_LIBPATH="$PKG_LIBNAME"

make_target() {
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_LIBPATH $INSTALL/usr/lib/libretro/
}