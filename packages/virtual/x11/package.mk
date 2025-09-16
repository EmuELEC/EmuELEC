# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="x11"
PKG_VERSION=""
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain xorg-server"
PKG_SECTION="virtual"
PKG_LONGDESC="X11 is the Windowing system"

# Additional packages we need for using xorg-server:
# Fonts
  PKG_DEPENDS_TARGET+=" encodings font-xfree86-type1 font-bitstream-type1 font-misc-misc"

# Server
  PKG_DEPENDS_TARGET+=" xkeyboard-config xkbcomp"

# Tools
  PKG_DEPENDS_TARGET+=" xrandr setxkbmap"

if [ -n "${WINDOWMANAGER}" -a "${WINDOWMANAGER}" != "no" ]; then
  PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
fi

get_graphicdrivers

# Drivers
if [ -n "${LIBINPUT}" ]; then
  PKG_DEPENDS_TARGET+=" xf86-input-libinput"
else
  PKG_DEPENDS_TARGET+=" xf86-input-evdev xf86-input-synaptics"
fi

for drv in ${XORG_DRIVERS}; do
  PKG_DEPENDS_TARGET+=" xf86-video-${drv}"
done
