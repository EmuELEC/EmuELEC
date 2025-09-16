# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="dbus-glib"
PKG_VERSION="0.112"
PKG_SHA256="7d550dccdfcd286e33895501829ed971eeb65c614e73aadb4a08aeef719b143a"
PKG_LICENSE="GPL"
PKG_SITE="https://freedesktop.org/wiki/Software/dbus"
PKG_URL="https://dbus.freedesktop.org/releases/dbus-glib/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain dbus glib expat"
PKG_LONGDESC="A message bus, used for sending messages between applications."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic +lto"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_have_abstract_sockets=yes \
                           ac_cv_func_posix_getpwnam_r=yes \
                           have_abstract_sockets=yes \
                           --enable-static \
                           --disable-shared \
                           --disable-tests \
                           --disable-bash-completion \
                           --enable-asserts=no"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin/dbus-binding-tool
}
