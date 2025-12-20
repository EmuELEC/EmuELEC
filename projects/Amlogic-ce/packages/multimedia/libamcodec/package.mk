# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libamcodec"
PKG_LICENSE="proprietary"
PKG_SITE="http://openlinux.amlogic.com"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libamplayer: Interface library for Amlogic media codecs"
PKG_TOOLCHAIN="manual"

case "${DEVICE}" in
  Amlogic-ng*)
    PKG_VERSION="eb874808303936404027f3fc7f7434285d0a7d2f"
    PKG_SHA256="9465b1029aa8ca7e2d1c5ffc3c2c9c5c524682e1c84321d91766dbdc3f26ccb6"
    ;;
  Amlogic-ne)
    PKG_VERSION="0f27efb9e958eaa66144709f1964179a019f5c32"
    PKG_SHA256="9cd7497999bdf4a709aee8e0cefe51940b40b9091dc831dfc08509d82637da30"
    ;;
esac

PKG_SOURCE_NAME="${PKG_NAME}-${ARCH}-${PKG_VERSION}.tar.xz"
PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"

make_target() {
  cp -PR * $SYSROOT_PREFIX
}

makeinstall_target() {
  mkdir -p $INSTALL/usr
    cp -PR usr/lib $INSTALL/usr
}
