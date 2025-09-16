# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vdr-plugin-live"
PKG_VERSION="3.1.6"
PKG_SHA256="8231f22d397b6cc954615304a12319fb74553aa67fbf12536b1df6727f69b8a2"
PKG_LICENSE="GPL"
PKG_SITE="http://live.vdr-developer.org/en/index.php"
PKG_URL="https://github.com/MarkusEh/vdr-plugin-live/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain vdr tntnet pcre2:host pcre2"
PKG_NEED_UNPACK="$(get_pkg_directory vdr)"
PKG_LONGDESC="Allows a comfortable operation of VDR and some of its plugins through a web interface."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+pic -parallel"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib/iconv"
}

make_target() {
  VDR_DIR=$(get_build_dir vdr)
  export CPLUS_INCLUDE_PATH=${VDR_DIR}/include
  VDR_APIVERSION=$(sed -ne '/define APIVERSION/s/^.*"\(.*\)".*$/\1/p' ${VDR_DIR}/config.h)
  LIB_NAME=lib${PKG_NAME/-plugin/}

  make VDRDIR=${VDR_DIR} \
    LIBDIR="." \
    LOCALEDIR="./locale" \
    all install-i18n

  cp --remove-destination ${PKG_BUILD}/${LIB_NAME}.so ${PKG_BUILD}/${LIB_NAME}.so.${VDR_APIVERSION}
}
