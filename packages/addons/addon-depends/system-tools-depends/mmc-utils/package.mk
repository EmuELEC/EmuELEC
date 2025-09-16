# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mmc-utils"
PKG_VERSION="c62dd8e415b12cc7f9a362db23cd384caf77ff03" # 2022-11-09
PKG_SHA256="181ec6a2657f19472672372a80488a624be3e9368176b836404ca29c1405374a"
PKG_LICENSE="GPL"
PKG_SITE="https://www.kernel.org/doc/html/latest/driver-api/mmc/mmc-tools.html"
PKG_URL="https://git.kernel.org/pub/scm/utils/mmc/mmc-utils.git/snapshot/mmc-utils-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Configure MMC storage devices from userspace."
PKG_BUILD_FLAGS="-sysroot"
