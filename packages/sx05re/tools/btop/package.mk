# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="btop"
PKG_VERSION="1.4.0"
PKG_SHA256="ac0d2371bf69d5136de7e9470c6fb286cbee2e16b4c7a6d2cd48a14796e86650"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/aristocratos/btop"
PKG_URL="https://github.com/aristocratos/btop/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="btop resource monitor"
PKG_TOOLCHAIN="auto"

post_makeinstall_target() {
  cat >${INSTALL}/usr/share/btop/btop.conf <<EOF
disks_filter = "/flash /storage /storage/roms"
use_fstab = False
update_ms = 1000
proc_gradient = False
EOF
}
