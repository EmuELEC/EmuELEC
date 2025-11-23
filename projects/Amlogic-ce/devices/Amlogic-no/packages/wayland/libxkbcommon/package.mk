# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxkbcommon"
PKG_VERSION="1.12.1"
PKG_SHA256="bb1543d956a5b962ee414174e9882c5d6fac3af9f95ebf48defb105151780ed1"
PKG_LICENSE="MIT"
PKG_SITE="https://xkbcommon.org"
PKG_URL="https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain xkeyboard-config libxml2"
PKG_LONGDESC="xkbcommon is a library to handle keyboard descriptions."

PKG_MESON_OPTS_TARGET="-Denable-docs=false"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=true \
                           -Denable-wayland=false"
elif [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland wayland-protocols"
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=false \
                           -Denable-wayland=true"
else
  PKG_MESON_OPTS_TARGET+=" -Denable-x11=false \
                           -Denable-wayland=false"
fi

pre_configure_target() {
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    TARGET_LDFLAGS="${LDFLAGS} -lXau -lxcb"
  fi
}
