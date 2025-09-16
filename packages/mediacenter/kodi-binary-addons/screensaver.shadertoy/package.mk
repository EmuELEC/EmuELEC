# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="screensaver.shadertoy"
PKG_VERSION="20.2.0-Nexus"
PKG_SHA256="91500d2c4eb97390d77fbaf5700ee472c41afa30cb76c6ecbe7e2683a14795fc"
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/xbmc/screensaver.shadertoy"
PKG_URL="https://github.com/xbmc/screensaver.shadertoy/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform glm"
PKG_SECTION=""
PKG_SHORTDESC="screensaver.shadertoy"
PKG_LONGDESC="screensaver.shadertoy"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.ui.screensaver"

if [ ! "${OPENGL}" = "no" ]; then
# for OpenGL (GLX) support
  PKG_DEPENDS_TARGET+=" ${OPENGL} glew"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
# for OpenGL-ES support
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi
