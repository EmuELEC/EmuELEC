# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-dbus"
PKG_VERSION="$(get_pkg_version dbus)"
PKG_NEED_UNPACK="$(get_pkg_directory dbus)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://dbus.freedesktop.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-expat lib32-systemd-libs"
PKG_PATCH_DIRS+=" $(get_pkg_directory dbus)/patches"
PKG_LONGDESC="D-Bus is a message bus, used for sending messages between applications."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="export ac_cv_have_abstract_sockets=yes \
                           --with-sysroot=${LIB32_SYSROOT_PREFIX} \
                           --libexecdir=/usr/lib/dbus \
                           --disable-verbose-mode \
                           --disable-asserts \
                           --enable-checks \
                           --disable-tests \
                           --disable-ansi \
                           --disable-xml-docs \
                           --disable-doxygen-docs \
                           --disable-x11-autolaunch \
                           --disable-selinux \
                           --disable-libaudit \
                           --enable-systemd \
                           --enable-inotify \
                           --without-valgrind \
                           --without-x \
                           --with-dbus-user=dbus \
                           --runstatedir=/run \
                           --with-system-socket=/run/dbus/system_bus_socket"


unpack() {
  ${SCRIPTS}/get dbus
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/dbus/dbus-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/etc
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
