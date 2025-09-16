# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vadumpcaps"
PKG_VERSION="38a446e33de5e65f0e5d263dd9a262a4e316a461"
PKG_SHA256="04847fcae7ed5529371c3ff27518e6ef4623db65955ad6c7633a538c6b2aeae8"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/fhvwy/vadumpcaps"
PKG_URL="https://github.com/fhvwy/vadumpcaps/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="This is a utility to show all capabilities of a VAAPI device/driver."
PKG_DEPENDS_TARGET="toolchain libva"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp vadumpcaps ${INSTALL}/usr/bin
}
