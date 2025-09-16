# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="intel-vaapi-driver"
PKG_VERSION="2.4.1"
PKG_SHA256="03cd7e16acc94f828b6e7f3087863d8ca06e99ffa3385588005b1984bdd56157"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL"
PKG_SITE="https://01.org/linuxmedia"
PKG_URL="https://github.com/intel/intel-vaapi-driver/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libva libdrm"
PKG_LONGDESC="intel-vaapi-driver: VA-API user mode driver for Intel GEN Graphics family"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  DISPLAYSERVER_LIBVA="-Dwith_x11=yes -Dwith_wayland=no"
elif [ "${DISPLAYSERVER}" = "wl" ]; then
  DISPLAYSERVER_LIBVA="-Dwith_x11=no -Dwith_wayland=yes"
else
  DISPLAYSERVER_LIBVA="-Dwith_x11=no -Dwith_wayland=no"
fi

PKG_MESON_OPTS_TARGET="-Denable_hybrid_codec=false \
                       -Denable_tests=false \
                       ${DISPLAYSERVER_LIBVA}"

