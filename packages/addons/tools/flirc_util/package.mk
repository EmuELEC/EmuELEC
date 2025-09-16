# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="flirc_util"
PKG_VERSION="8d3c86e8bb419ad44297c1b186f0cdc7dfcac915" # 30/10/2023
PKG_SHA256="fc460e6ce5477cb6b83c90a5f8b2ebb9876ed23cdd813a6a4a0fdc3730052a2b"
PKG_LICENSE="FLIRC"
PKG_SITE="http://www.flirc.tv"
PKG_URL="https://github.com/flirc/sdk/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain hidapi libusb"
PKG_SECTION="tools"
PKG_SHORTDESC="CLI utility for flirc IR receivers"
PKG_LONGDESC="Command-Line utility for configuring flirc IR receivers"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="flirc_util"
PKG_ADDON_TYPE="xbmc.python.script"

make_target() {
  cd cli
  make VERBOSE="1" \
       CONFIG="release" \
       HOSTOS="LIBREELEC" \
       MACHINE="Linux_${TARGET_ARCH}" \
       BUILDDIR_ROOT="${PKG_BUILD}/build" \
       BUILDDIR="${PKG_BUILD}/build" \
       LSEARCH+=" -L../libs/Linux_${TARGET_ARCH}" \
       flirc_util
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,lib}
    cp -P ${PKG_BUILD}/build/flirc_util ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/
    cp -P $(get_install_dir hidapi)/usr/lib/libhidapi-hidraw.so* ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
}
