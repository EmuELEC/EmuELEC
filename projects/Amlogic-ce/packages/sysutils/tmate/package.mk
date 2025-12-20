# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="tmate"
PKG_VERSION="ac919516f4f1b10ec928e20b3a5034d18f609d68"
PKG_SHA256="a3acd7880e2cca0b2a3bd2d0071ae8ec2aeb0326ccf699b57f519d4a6d0258a2"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/tmate-io/tmate"
PKG_URL="https://github.com/tmate-io/tmate/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libevent libssh msgpack-c"
PKG_LONGDESC="Instant terminal sharing."
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
  export LIBS+=" -lz -lcrypto"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp tmate ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib/libreelec
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/lib/libreelec
}

post_install() {
  enable_service tmate.service
}
