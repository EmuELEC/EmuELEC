# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="wlan-firmware"
PKG_VERSION="c0ad2587a8037ca430fd887602bd739d769fdbc5"
PKG_SHA256="cd019a209f1dd0c76caa9cf382231e86ef07e4448ff3c81b3d1d76b6bde6ca67"
PKG_LICENSE="Free-to-use"
PKG_SITE="https://github.com/LibreELEC/wlan-firmware"
PKG_URL="https://github.com/LibreELEC/wlan-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="wlan-firmware: firmwares for various WLAN drivers"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  DESTDIR=${INSTALL}/$(get_kernel_overlay_dir) ./install
}
