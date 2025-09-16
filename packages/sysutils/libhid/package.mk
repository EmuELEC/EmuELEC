# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libhid"
PKG_VERSION="9bbcb6484c91e2594614412e12ae85a144839634" # 0.2.17 + fixes
PKG_SHA256="983c6fa0b46b67805a81eb600a6c4728b645ac7b014b4897d5aa212576105567"
PKG_LICENSE="GPL"
PKG_SITE="http://libhid.alioth.debian.org/"
PKG_URL="https://github.com/chad3814/libhid/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libusb-compat libusb"
PKG_LONGDESC="libhid provides a generic and flexible way to access and interact with USB HID devices."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared \
            --enable-static \
            --disable-werror \
            --disable-swig"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr
}
