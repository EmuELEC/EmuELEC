# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xa"
PKG_VERSION="2.3.10"
PKG_SHA256="867b5b26b6524be8bcfbad8820ab3efe422b3e0cc9775dcb743284778868ba78"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE="https://www.floodgap.com/retrotech/xa/dists"
PKG_URL="${PKG_SITE}/xa-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="xa is a high-speed, two-pass portable cross-assembler. It understands mnemonics and generates code for NMOS 6502s (such as 6502A, 6504, 6507, 6510, 7501, 8500, 8501, 8502 ...), CMOS 6502s (65C02 and Rockwell R65C02) and the 65816. "

makeinstall_host() {
  cp xa ${TOOLCHAIN}/bin/
}
