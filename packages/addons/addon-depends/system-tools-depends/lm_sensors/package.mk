# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lm_sensors"
PKG_VERSION="3.6.0"
PKG_SHA256="0591f9fa0339f0d15e75326d0365871c2d4e2ed8aa1ff759b3a55d3734b7d197"
PKG_LICENSE="GPL"
PKG_SITE="https://hwmon.wiki.kernel.org"
PKG_URL="https://github.com/groeck/lm-sensors/archive/V${PKG_VERSION//./-}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Provides user-space support for the hardware monitoring drivers."
PKG_BUILD_FLAGS="-sysroot"

pre_make_target() {
  PKG_MAKE_OPTS_TARGET="PREFIX=/usr CC=${CC} AR=${AR}"

  export CFLAGS="${TARGET_CFLAGS}"
  export CPPFLAGS="${TARGET_CPPFLAGS}"

  sed -i 's|^EXLDFLAGS :=.*|EXLDFLAGS :=|' Makefile
}

pre_makeinstall_target() {
  PKG_MAKEINSTALL_OPTS_TARGET="PREFIX=/usr CC=${CC} AR=${AR}"
}
