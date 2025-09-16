# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="qca9377-firmware-aml"
PKG_VERSION="1.0.0-3"
PKG_SHA256="9a9f214943e77e89ce8fc8c0dc5b41bc253478a9d92383a76590993df861f36d"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3c"
PKG_SITE="http://linode.boundarydevices.com/repos/apt/ubuntu-relx/pool/main/q/qca-firmware/"
PKG_URL="$DISTRO_SRC/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="qca9377 Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_firmware_dir)
    cp -a * $INSTALL/$(get_full_firmware_dir)
}
