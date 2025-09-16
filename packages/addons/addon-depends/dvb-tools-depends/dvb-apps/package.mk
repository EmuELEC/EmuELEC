# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dvb-apps"
PKG_VERSION="3d43b280298c"
PKG_SHA256="f39e2f0ebed7e32bce83522062ad4d414f67fccd5df1b647618524497e15e057"
PKG_LICENSE="GPL"
PKG_SITE="https://www.linuxtv.org/wiki/index.php/LinuxTV_dvb-apps"
PKG_URL="https://linuxtv.org/hg/dvb-apps/archive/${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Applications for initial setup, testing and operation of an DVB device supporting the DVB-S, DVB-C, DVB-T, and ATSC."
PKG_BUILD_FLAGS="-sysroot"

pre_make_target() {
  export PERL_USE_UNSAFE_INC=1
}
