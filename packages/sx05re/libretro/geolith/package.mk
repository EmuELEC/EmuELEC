# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/emuelec)

PKG_NAME="geolith"
PKG_VERSION="0a104c839bba8240e4c6b19e08013c150c31ddcd"
PKG_SHA256="4abbcdf6acbcfc810b73e8f1b62e064396c6a02359645c414b4ca04584cd61e1"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Highly accurate emulator for the Neo Geo AES and MVS Cartridge Systems"
PKG_TOOLCHAIN="make"

make_target() {
cd libretro
  make -f ./Makefile platform=rpi3_64
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp geolith_libretro.so ${INSTALL}/usr/lib/libretro/
}
