# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtl8822b_bt"
PKG_VERSION="4dfa50ab6150aa51a6e03bbcd479c8d2e68bfa2b"
PKG_SHA256="bf9205c4ac1a5893cdbd3ca98ab82e5636244fef50e375fc0148a3db7153fe51"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ChalesYu/rtl8822bs-aml"
PKG_URL="https://github.com/ChalesYu/rtl8822bs-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain rkbin"
PKG_LONGDESC="RTL8822B BT Linux firmware"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p $PKG_BUILD
  tar --strip-components=2 -xf $SOURCES/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.gz -C $PKG_BUILD rtl8822bs-aml-$PKG_VERSION/bluetooth
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
    cp -a $(get_build_dir rkbin)/firmware/bin/rtk_hciattach $INSTALL/usr/bin/8822b_hciattach

  mkdir -p $INSTALL/$(get_full_firmware_dir)/rtlbt
    cp -a $PKG_BUILD/rtl8822b_config.bin $INSTALL/$(get_full_firmware_dir)/rtlbt/rtl8822b_config
    cp -a $PKG_BUILD/rtl8822b_fw.bin $INSTALL/$(get_full_firmware_dir)/rtlbt/rtl8822b_fw
}
