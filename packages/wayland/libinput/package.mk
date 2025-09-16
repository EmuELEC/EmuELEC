# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libinput"
PKG_VERSION="1.22.1"
PKG_SHA256="e13f6f118cfbbdc0b6e0edd5e3504abd96a8d0e33dc67cba31c6942c449f77af"
PKG_LICENSE="GPL"
PKG_SITE="https://www.freedesktop.org/wiki/Software/libinput/"
PKG_URL="https://gitlab.freedesktop.org/libinput/libinput/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain systemd libevdev mtdev"
PKG_LONGDESC="libinput is a library to handle input devices in Wayland compositors and to provide a generic X.Org input driver."

PKG_MESON_OPTS_TARGET="-Dlibwacom=false \
                       -Ddebug-gui=false \
                       -Dtests=false \
                       -Ddocumentation=false"
