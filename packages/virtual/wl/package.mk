# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wl"
PKG_VERSION=""
PKG_LICENSE="OSS"
PKG_SITE="https://wayland.freedesktop.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_LONGDESC="Wayland is intended as a simpler replacement for X, easier to develop and maintain."

# Compositor
if [ -n "${WINDOWMANAGER}" -a "${WINDOWMANAGER}" != "no" ]; then
  PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
fi

# Tools for wlroots based compositors
if [  "${WINDOWMANAGER}" = "sway" ]; then
  PKG_DEPENDS_TARGET+=" wlr-randr"
fi

# NVIDIA drivers for Linux
if listcontains "${GRAPHIC_DRIVERS}" "nvidia-ng"; then
  PKG_DEPENDS_TARGET+=" nvidia"
fi
