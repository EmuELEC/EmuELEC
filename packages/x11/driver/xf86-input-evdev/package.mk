# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xf86-input-evdev"
PKG_VERSION="2.10.6"
PKG_SHA256="8726073e81861bc7b2321e76272cbdbd33c7e1a121535a9827977265b9033ec0"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/driver/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain xorg-server util-macros libevdev mtdev systemd"
PKG_LONGDESC="Evdev is an Xorg input driver for Linux's generic event devices."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-silent-rules \
                           --with-xorg-module-dir=${XORG_PATH_MODULES} \
                           --with-gnu-ld"
