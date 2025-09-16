# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="hidapi"
PKG_VERSION="0.14.0"
PKG_SHA256="a5714234abe6e1f53647dd8cba7d69f65f71c558b7896ed218864ffcf405bcbd"
PKG_LICENSE="HIDAPI-orig"
PKG_SITE="http://libusb.info/"
PKG_URL="https://github.com/libusb/hidapi/archive/refs/tags/hidapi-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libusb"
PKG_LONGDESC="HIDAPI is a multi-platform library which allows an application to interface with USB and Bluetooth HID-Class devices."
PKG_TOOLCHAIN="cmake"
