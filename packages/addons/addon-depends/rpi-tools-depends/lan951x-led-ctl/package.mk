# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lan951x-led-ctl"
PKG_VERSION="1.0"
PKG_SHA256="27d607d3c5c7b142681dcd9fd0afecb7fcb052abfaffc330b28906f782e602f3"
PKG_ARCH="arm"
PKG_LICENSE="GPL"
PKG_SITE="https://familie-radermacher.ch/dominic/computer/raspberry-pi/lan951x-led-ctl/"
PKG_URL="https://mockmoon-cybernetics.ch/cgi/cgit/lan951x-led-ctl.git/snapshot/lan951x-led-ctl-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libusb"
PKG_LONGDESC="Control LEDs connected to LAN9512/LAN9514 ethernet USB controllers."
PKG_TOOLCHAIN="manual"

make_target() {
  ${CC} -std=c11 -I./include -Wall -Wstrict-prototypes -Wconversion \
      -Wmissing-prototypes -Wshadow -Wextra -Wunused \
      ${CFLAGS} -lusb-1.0 ${LDFLAGS} -o lan951x-led-ctl src/lan951x-led-ctl.c

  ${STRIP} lan951x-led-ctl
}
