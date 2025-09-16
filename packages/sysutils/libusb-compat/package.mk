# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="libusb-compat"
PKG_VERSION="0.1.7"
PKG_SHA256="8259f8d5b084fe43c47823a939e955e0ba21942b8d112266c39d228cc14764d6"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libusb/libusb-compat-0.1"
PKG_URL="https://github.com/libusb/libusb-compat-0.1/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libusb"
PKG_LONGDESC="The libusb project's aim is to create a Library for use by user level applications to USB devices."

PKG_CONFIGURE_OPTS_TARGET="--disable-log \
                           --disable-debug-log \
                           --disable-examples-build"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
  sed -e "s:\(['= ]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/libusb-config
}
