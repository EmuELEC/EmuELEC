# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ngrep"
PKG_VERSION="2a9603bc67dface9606a658da45e1f5c65170444" # 2019-01-29
PKG_SHA256="500c29914dd26f5aa6df07446388d49b60249622c9b0fd1f266f62a5706f056c"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/jpr5/ngrep"
PKG_URL="https://github.com/jpr5/ngrep/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpcap pcre2"
PKG_LONGDESC="A tool like GNU grep applied to the network layer."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot -parallel"

PKG_CONFIGURE_OPTS_TARGET="--with-pcap-includes=${SYSROOT_PREFIX}/usr/include \
                           --enable-ipv6 \
                           --enable-pcre2 \
                           --disable-dropprivs"

pre_build_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}
