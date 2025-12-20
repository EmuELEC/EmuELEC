# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mkbootimg"
PKG_VERSION="1.6.0"
PKG_SHA256="7930b7dba25e5b4a39e6d19ccce9005e17c98a2b6c9e1aa6408a88c716755aaf"
PKG_LICENSE="GPL"
PKG_SITE="https://source.codeaurora.org/quic/kernel/skales/"
PKG_URL="https://source.codeaurora.org/quic/kernel/skales/snapshot/$PKG_VERSION.tar.xz"
PKG_DEPENDS_HOST="dtc:host"
PKG_LONGDESC="mkbootimg: Creates kernel boot images for Android"
PKG_TOOLCHAIN="manual"

make_host() {
  sed "s|libfdt.so|$TOOLCHAIN/lib/libfdt.so|" -i dtbTool
}

makeinstall_host() {
  cp mkbootimg $TOOLCHAIN/bin/
  cp dtbTool $TOOLCHAIN/bin/
}
