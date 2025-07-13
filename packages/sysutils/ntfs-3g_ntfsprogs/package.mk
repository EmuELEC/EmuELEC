# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ntfs-3g_ntfsprogs"
PKG_VERSION="2021.8.22"
PKG_SHA256="55b883aa05d94b2ec746ef3966cb41e66bed6db99f22ddd41d1b8b94bb202efb"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/tuxera/ntfs-3g"
PKG_URL="https://tuxera.com/opensource/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain fuse libgcrypt"
PKG_LONGDESC="A NTFS driver with read and write support."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+lto"

PKG_CONFIGURE_OPTS_TARGET="--exec-prefix=/usr/ \
                           --disable-dependency-tracking \
                           --disable-library \
                           --enable-posix-acls \
                           --enable-mtab \
                           --enable-ntfsprogs \
                           --disable-crypto \
                           --with-fuse=external \
                           --with-uuid"

post_makeinstall_target() {
  # dont include ntfsprogs.
  for i in ${INSTALL}/usr/bin/*; do
    if [ "$(basename ${i})" != "ntfs-3g" ]; then
      rm ${i}
    fi
  done

  rm -rf ${INSTALL}/sbin
  rm -rf ${INSTALL}/usr/sbin/ntfsclone
  rm -rf ${INSTALL}/usr/sbin/ntfscp
  rm -rf ${INSTALL}/usr/sbin/ntfsundelete

  mkdir -p ${INSTALL}/usr/sbin
    ln -sf /usr/bin/ntfs-3g ${INSTALL}/usr/sbin/mount.ntfs
    ln -sf /usr/sbin/mkntfs ${INSTALL}/usr/sbin/mkfs.ntfs
}
