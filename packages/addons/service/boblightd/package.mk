# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="boblightd"
PKG_VERSION="478"
PKG_SHA256="78b82c9b133ce20c3d24aba96abe4a8302ec8dc640460b3b7302aa1d368c543a"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://code.google.com/p/boblight"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libusb"
PKG_SECTION="service/multimedia"
PKG_SHORTDESC="Boblight: an AmbiLight controller"
PKG_LONGDESC="Boblight(${PKG_VERSION}) is an opensource AmbiLight implementation."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Boblight"
PKG_ADDON_TYPE="xbmc.service"
PKG_TOOLCHAIN="autotools"

if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" libX11 libXext libXrender"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" mesa glu"
fi

if [ "${OPENGL}" = "no" ]; then
  EXTRAOPTS="--without-opengl"
fi

if [ ! "${DISPLAYSERVER}" = "x11" ]; then
  EXTRAOPTS+=" --without-x11"
fi

PKG_CONFIGURE_OPTS_TARGET="${EXTRAOPTS} --without-portaudio"

makeinstall_target() {
  : # nothing to do here
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
  cp -P ${PKG_BUILD}/.${TARGET_NAME}/src/.libs/libboblight.so* ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  cp -P ${PKG_BUILD}/.${TARGET_NAME}/src/boblightd ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  cp -P ${PKG_BUILD}/.${TARGET_NAME}/src/boblight-constant ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    cp -P ${PKG_BUILD}/.${TARGET_NAME}/src/boblight-X11 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  fi

  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config
  cp -R ${PKG_DIR}/config/boblight.conf ${ADDON_BUILD}/${PKG_ADDON_ID}/config
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    cp -R ${PKG_DIR}/config/boblight.X11.sample ${ADDON_BUILD}/${PKG_ADDON_ID}/config
  fi
}
