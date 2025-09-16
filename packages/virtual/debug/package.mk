# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="debug"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="http://www.openelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain gdb edid-decode memtester strace"
PKG_SECTION="virtual"
PKG_LONGDESC="debug is a Metapackage for installing debugging tools"

# configure GPU drivers and dependencies:
  get_graphicdrivers

if [ "${VDPAU_SUPPORT}" = "yes" -a "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" vdpauinfo"
fi

if [ "${VAAPI_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libva-utils"
fi

if [ "${VALGRIND}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" valgrind"
fi

if [ "${REMOTE_GDB}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" gdb:host"
fi
