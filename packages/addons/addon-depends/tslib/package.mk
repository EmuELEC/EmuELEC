# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tslib"
PKG_VERSION="1.1"
PKG_SHA256="fe35e5f710ea933b118f710e2ce4403ac076fe69926b570333867d4de082a51c"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kergoth/tslib"
PKG_URL="https://github.com/kergoth/tslib/releases/download/1.1/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain evtest"
PKG_LONGDESC="Touchscreen access library with ts_uinput_touch daemon."
PKG_TOOLCHAIN="autotools"

TSLIB_MODULES_ENABLED="linear dejitter variance pthres ucb1x00 tatung input galax dmc touchkit st1232 waveshare"
TSLIB_MODULES_DISABLED="arctic2 corgi collie h3600 linear_h2200 mk712 cy8mrln_palmpre"
TSLIB_BUILD_STATIC="yes"  # no .so files (easy to manage)

pre_configure_target() {
  local OPTS_MODULES=""

  if [ "${TSLIB_BUILD_STATIC}" = "yes" ]; then
    OPTS_MODULES="--enable-static --disable-shared"
    for module in ${TSLIB_MODULES_ENABLED}; do
      OPTS_MODULES+=" --enable-${module}=static"
    done
  fi

  for module in ${TSLIB_MODULES_DISABLED}; do
    OPTS_MODULES+=" --disable-${module}"
  done

  PKG_CONFIGURE_OPTS_TARGET="${OPTS_MODULES} \
    --sysconfdir=/storage/.kodi/userdata/addon_data/service.touchscreen"
}

post_makeinstall_target() {
  rm -fr ${INSTALL}/etc
  rm -fr ${INSTALL}/storage

  debug_strip ${INSTALL}/usr/bin
}
