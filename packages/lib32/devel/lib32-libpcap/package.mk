# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present EmuELEC (https://github.com/EmuELEC)

PKG_NAME="lib32-libpcap"
PKG_VERSION="$(get_pkg_version libpcap)"
PKG_NEED_UNPACK="$(get_pkg_directory libpcap)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/libs/libpcap/libpcap.git/log/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libpcap)/patches"
PKG_LONGDESC="A library for getting and setting POSIX.1e capabilities."
PKG_BUILD_FLAGS="+pic lib32"
PKG_TOOLCHAIN="configure"

unpack() {
  ${SCRIPTS}/get libpcap
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libpcap/libpcap-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_unpack() {
  mkdir -p ${PKG_BUILD}/.${LIB32_TARGET_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${LIB32_TARGET_NAME}
}

PKG_CONFIGURE_OPTS_TARGET="LIBS=-lpthread \
                           ac_cv_header_libusb_1_0_libusb_h=no \
                           --disable-shared \
                           --with-pcap=linux \
                           --disable-bluetooth \
                           --disable-can \
                           --without-libnl \
                           --disable-dbus \
                           --disable-canusb"
      
pre_configure_target() {
# When cross-compiling, configure can't set linux version
# forcing it
  sed -i -e 's/ac_cv_linux_vers=unknown/ac_cv_linux_vers=2/' ../configure
}


post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
