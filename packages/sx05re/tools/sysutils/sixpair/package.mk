# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sixpair"
PKG_VERSION="23e6e087fe7f013128ce2e0e19a8f4b04fa7a6e8"
PKG_SHA256="9fc491060a85a01789a88e4dcb5271806ff6c7fbe62b58f828ac83ed1b4de1fe"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.pabr.org/sixlinux/"
PKG_URL="https://github.com/lakkatv/sixpair/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libusb libusb-compat"
PKG_SECTION="network"
PKG_SHORTDESC="Associate PS3 Sixaxis controller to system bluetoothd via USB"
PKG_LONGDESC="Associate PS3 Sixaxis controller to system bluetoothd via USB"
PKG_TOOLCHAIN="make"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

make_target() {
  make sixpair LDLIBS=-lusb
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp sixpair ${INSTALL}/usr/bin
}

