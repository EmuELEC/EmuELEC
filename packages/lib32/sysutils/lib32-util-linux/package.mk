# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-util-linux"
PKG_VERSION="$(get_pkg_version util-linux)"
PKG_NEED_UNPACK="$(get_pkg_directory util-linux)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory util-linux)/patches"
PKG_LONGDESC="A large variety of low-level system utilities that are necessary for a Linux system to function."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic:host lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-gtk-doc \
                           --disable-nls \
                           --disable-rpath \
                           --enable-tls \
                           --enable-chsh-only-listed \
                           --disable-bash-completion \
                           --disable-colors-default \
                           --disable-pylibmount \
                           --disable-pg-bell \
                           --disable-use-tty-group \
                           --disable-makeinstall-chown \
                           --disable-makeinstall-setuid \
                           --with-gnu-ld \
                           --without-selinux \
                           --without-audit \
                           --without-udev \
                           --without-ncurses \
                           --without-ncursesw \
                           --without-readline \
                           --without-slang \
                           --without-tinfo \
                           --without-utempter \
                           --without-util \
                           --without-libz \
                           --without-user \
                           --without-systemd \
                           --without-smack \
                           --without-python \
                           --without-systemdsystemunitdir \
                           --disable-all-programs \
                           --enable-libblkid \
                           --enable-libmount"

unpack() {
  ${SCRIPTS}/get util-linux
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/util-linux/util-linux-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
