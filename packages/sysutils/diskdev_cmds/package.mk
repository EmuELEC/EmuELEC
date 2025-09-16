# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="diskdev_cmds"
PKG_VERSION="332.14"
PKG_SHA256="a46bec392661a02d9683355baf4442d494e2bcde0ffb094aacc1e57ddc03b3d4"
PKG_LICENSE="APSL"
PKG_SITE="http://src.gnu-darwin.org/DarwinSourceArchive/expanded/diskdev_cmds/"
PKG_URL="http://www.opensource.apple.com/tarballs/diskdev_cmds/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl"
PKG_LONGDESC="The fsck and mkfs utliities for hfs and hfsplus filesystems."

pre_make_target() {
  PKG_MAKE_OPTS_TARGET="-f Makefile.lnx CC=${CC}"

  export CFLAGS="${TARGET_CFLAGS} -g3 -Wall -I${PKG_BUILD}/include -DDEBUG_BUILD=0 -D_FILE_OFFSET_BITS=64 -D LINUX=1 -D BSD=1"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
    cp fsck_hfs.tproj/fsck_hfs ${INSTALL}/usr/sbin
      ln -sf fsck_hfs ${INSTALL}/usr/sbin/fsck.hfs
      ln -sf fsck_hfs ${INSTALL}/usr/sbin/fsck.hfsplus
}

make_init() {
  : # we reuse make_target()
}
