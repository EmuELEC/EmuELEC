# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="joyutils"
PKG_VERSION="b6703ebf04c839fc47f9e490b68c4d5d885f32f9"
PKG_SHA256="73914d760d44542fa5b88ab42f914713e07e184c299415fdbe8abd83e68dc200"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/datrh/joyutils"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="tools"
PKG_SHORTDESC="jscal, jstest, and jsattach utilities for the Linux joystick driver"
PKG_LONGDESC="jscal, jstest, and jsattach utilities for the Linux joystick driver"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

# post_unpack() {
#  mv ${BUILD}/joystick-${PKG_VERSION} ${BUILD}/${PKG_NAME}-${PKG_VERSION}
# }

make_target() {
  ${CC} -lm -o jscal jscal.c ${CFLAGS}
  ${CC} -lm -o jstest jstest.c ${CFLAGS}
  ${CC} -lm -o jsattach jsattach.c ${CFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp jscal ${INSTALL}/usr/bin/
  cp jstest ${INSTALL}/usr/bin/
  cp jsattach ${INSTALL}/usr/bin/
}
