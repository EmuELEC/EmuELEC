# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="toolchain"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_HOST="autoconf:host autoconf-archive:host automake:host bison:host configtools:host cmake:host flex:host intltool:host libtool:host ninja:host make:host meson:host openssl:host p7zip:host pigz:host sed:host xmlstarlet:host xz:host"
PKG_DEPENDS_TARGET="toolchain:host gcc:host"
PKG_SECTION="virtual"
PKG_LONGDESC="LibreELEC.tv' toolchain to compile all packages"
