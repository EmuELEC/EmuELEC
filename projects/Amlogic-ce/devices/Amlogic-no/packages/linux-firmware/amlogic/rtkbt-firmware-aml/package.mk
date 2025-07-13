# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtkbt-firmware-aml"
PKG_VERSION="4d95579f256383af2df39d796f38a91ee6ec0b80"
PKG_SHA256="7a2884532969f84596f469cde599b8ecc026e80263ae64c9faf0e22a0332f569"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/rtkbt-firmware-aml"
PKG_URL="https://github.com/CoreELEC/rtkbt-firmware-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain rtk_hciattach"
PKG_LONGDESC="Realtek BT Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  FWDIR=$INSTALL/$(get_full_firmware_dir)/rtlbt

  mkdir -p $FWDIR
    cp -a $PKG_BUILD/* $FWDIR
}
