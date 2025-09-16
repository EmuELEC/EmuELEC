# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nmon"
PKG_VERSION="16n"
PKG_SHA256="c0012cc2d925dee940c37ceae297abac64ba5a5c30e575e7418b04028613f5f2"
PKG_LICENSE="GPL"
PKG_SITE="http://nmon.sourceforge.net/pmwiki.php?n=Site.CompilingNmon"
PKG_URL="http://sourceforge.net/projects/nmon/files/lmon16n.c"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="Systems administrator, tuner, benchmark tool gives you a huge amount of important performance information in one go."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

unpack() {
  mkdir -p ${PKG_BUILD}
  cp -p ${SOURCES}/nmon/${PKG_SOURCE_NAME} ${PKG_BUILD}
}

make_target() {
  case ${ARCH} in
    x86_64)
      arch="X86"
      ;;
    *)
      arch="arm"
      ;;
  esac
  # original makefile is located at
  # - https://downloads.sourceforge.net/project/nmon/makefile
  CFLAGS+=" -g -O3 -Wall -D JFS -D GETUSER -D LARGEMEM"
  LDFLAGS+=" -lncurses -lm -g"
  ${CC} -o nmon nmon-${PKG_VERSION}.c ${CFLAGS} ${LDFLAGS} -D ${arch} -DUBUNTU
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -p nmon ${INSTALL}/usr/bin
}
