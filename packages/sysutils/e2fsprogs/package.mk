# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="e2fsprogs"
PKG_VERSION="1.46.6"
PKG_SHA256="a77517f19ff5e4e97ede63536566865dd5d48654e13fc145f5f2249ef7c4f4fc"
PKG_LICENSE="GPL"
PKG_SITE="http://e2fsprogs.sourceforge.net/"
PKG_URL="https://www.kernel.org/pub/linux/kernel/people/tytso/${PKG_NAME}/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_INIT="toolchain"
PKG_LONGDESC="The filesystem utilities for the EXT2 filesystem, including e2fsck, mke2fs, dumpe2fs, fsck, and others."
PKG_BUILD_FLAGS="-parallel"

PKG_CONFIGURE_OPTS_HOST="--prefix=${TOOLCHAIN}/ \
                         --bindir=${TOOLCHAIN}/bin \
                         --sbindir=${TOOLCHAIN}/sbin \
                         --disable-debugfs \
                         --disable-defrag \
                         --disable-e2initrd-helper \
                         --disable-fsck \
                         --disable-fuse2fs \
                         --disable-imager \
                         --disable-nls \
                         --disable-resizer \
                         --disable-rpath \
                         --disable-subset \
                         --disable-symlink-build \
                         --disable-symlink-install \
                         --enable-tls \
                         --disable-uuidd \
                         --enable-verbose-makecmds \
                         --with-crond-dir=no \
                         --with-gnu-ld \
                         --without-pthread \
                         --with-systemd-unit-dir=no \
                         --with-udev-rules-dir=no"

post_unpack() {
  # Increase minimal inode size to avoid:
  # "ext4 filesystem being mounted at xxx supports timestamps until 2038 (0x7fffffff)"
  sed -i 's/inode_size = 128/inode_size = 256/g' ${PKG_BUILD}/misc/mke2fs.conf.in
}

pre_configure() {
  PKG_CONFIGURE_OPTS_INIT="BUILD_CC=${HOST_CC} \
                           --disable-blkid-debug \
                           --disable-bsd-shlibs \
                           --disable-debugfs \
                           --disable-e2initrd-helper \
                           --disable-elf-shlibs \
                           --enable-fsck \
                           --disable-fuse2fs \
                           --disable-imager \
                           --disable-jbd-debug \
                           --enable-libblkid \
                           --enable-libuuid \
                           --disable-nls \
                           --disable-profile \
                           --enable-resizer \
                           --disable-rpath \
                           --disable-subset \
                           --enable-symlink-build \
                           --enable-symlink-install \
                           --disable-testio-debug \
                           --enable-tls \
                           --disable-uuidd \
                           --enable-verbose-makecmds \
                           --with-crond-dir=no \
                           --with-gnu-ld \
                           --without-pthread \
                           --with-systemd-unit-dir=no \
                           --with-udev-rules-dir=no"

  PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_INIT}"
}

post_makeinstall_target() {
  make -C lib/et LIBMODE=644 DESTDIR=${SYSROOT_PREFIX} install

  rm -rf ${INSTALL}/usr/sbin/badblocks
  rm -rf ${INSTALL}/usr/sbin/blkid
  rm -rf ${INSTALL}/usr/sbin/dumpe2fs
  rm -rf ${INSTALL}/usr/sbin/e2freefrag
  rm -rf ${INSTALL}/usr/sbin/e2undo
  rm -rf ${INSTALL}/usr/sbin/e4defrag
  rm -rf ${INSTALL}/usr/sbin/filefrag
  rm -rf ${INSTALL}/usr/sbin/fsck
  rm -rf ${INSTALL}/usr/sbin/logsave
  rm -rf ${INSTALL}/usr/sbin/mklost+found
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/sbin
    cp e2fsck/e2fsck ${INSTALL}/usr/sbin
    ln -sf e2fsck ${INSTALL}/usr/sbin/fsck.ext2
    ln -sf e2fsck ${INSTALL}/usr/sbin/fsck.ext3
    ln -sf e2fsck ${INSTALL}/usr/sbin/fsck.ext4

  if [ ${INITRAMFS_PARTED_SUPPORT} = "yes" ]; then
    cp misc/mke2fs ${INSTALL}/usr/sbin
    ln -sf mke2fs ${INSTALL}/usr/sbin/mkfs.ext2
    ln -sf mke2fs ${INSTALL}/usr/sbin/mkfs.ext3
    ln -sf mke2fs ${INSTALL}/usr/sbin/mkfs.ext4
  fi
}

makeinstall_host() {
  make -C lib/et LIBMODE=644 install
  make -C lib/ext2fs LIBMODE=644 install
  mkdir -p ${TOOLCHAIN}/sbin
  cp e2fsck/e2fsck ${TOOLCHAIN}/sbin
  cp misc/mke2fs ${TOOLCHAIN}/sbin
  cp misc/tune2fs ${TOOLCHAIN}/sbin
}
