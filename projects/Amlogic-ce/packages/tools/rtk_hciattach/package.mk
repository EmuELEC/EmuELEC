# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtk_hciattach"
PKG_VERSION="3d0ed39cfdd24343715057e93134cd63b7321827"
PKG_SHA256="6c5908e4e07fe4a74c54f5b58f01bdbeffc2aa2f8b529c5f32ce897e087edf7a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Caesar-github/rkwifibt"
PKG_URL="https://github.com/Caesar-github/rkwifibt/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Realtek BT FW loader"
PKG_TOOLCHAIN="make"

unpack() {
  mkdir -p $PKG_BUILD
  tar --strip-components=3 -xf $SOURCES/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.gz -C $PKG_BUILD rkwifibt-$PKG_VERSION/realtek/rtk_hciattach
}
