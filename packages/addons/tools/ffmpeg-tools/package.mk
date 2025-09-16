# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ffmpeg-tools"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain ffmpegx"
PKG_SECTION="tools"
PKG_SHORTDESC="FFmpeg binary for transcoding and audio/video manipulating."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="FFmpeg Tools"
PKG_ADDON_TYPE="xbmc.python.script"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,lib}

  cp -L $(get_install_dir ffmpegx)/usr/local/bin/* ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

  # libs
  if [ "${TARGET_ARCH}" = "x86_64" ]; then
    cp -PL $(get_install_dir x265)/usr/lib/libx265.so.199 \
           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
  fi
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    cp -PL $(get_install_dir libxcb)/usr/lib/{libxcb.so.1,libxcb-shm.so.0,libxcb-shape.so.0,libxcb-xfixes.so.0} \
           ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
  fi
}
