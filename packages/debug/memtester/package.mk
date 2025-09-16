# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="memtester"
PKG_VERSION="4.5.1"
PKG_SHA256="1c5fc2382576c084b314cfd334d127a66c20bd63892cac9f445bc1d8b4ca5a47"
PKG_LICENSE="GPL"
PKG_SITE="http://pyropus.ca/software/memtester/"
PKG_URL="http://pyropus.ca/software/memtester/old-versions/memtester-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A userspace utility for testing the memory subsystem for faults."
PKG_TOOLCHAIN="manual"

make_target() {
  make memtester
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp memtester ${INSTALL}/usr/bin
}
