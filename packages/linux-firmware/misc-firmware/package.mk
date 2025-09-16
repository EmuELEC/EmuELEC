# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="misc-firmware"
PKG_VERSION="868fb584096c17ddcbc85e472e71f9b8d27da91f"
PKG_SHA256="862a5a62b9794d7c6753ac0f7ae03fd34ee2564199afd61c42dc8f69d4c5b876"
PKG_LICENSE="Free-to-use"
PKG_SITE="https://github.com/LibreELEC/misc-firmware"
PKG_URL="https://github.com/LibreELEC/misc-firmware/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kernel-firmware"
PKG_LONGDESC="misc-firmware: firmwares for various drivers"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  DESTDIR=${INSTALL}/$(get_kernel_overlay_dir) ./install
}
