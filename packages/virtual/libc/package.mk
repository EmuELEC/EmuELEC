# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libc"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain glibc tz libidn2"
PKG_DEPENDS_INIT="toolchain glibc:init"
PKG_SECTION="virtual"
PKG_LONGDESC="Meta package for installing various tools and libs needed for libc"

if [ "${ARM_MEM_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" arm-mem"
  PKG_DEPENDS_INIT+=" arm-mem:init"
fi
