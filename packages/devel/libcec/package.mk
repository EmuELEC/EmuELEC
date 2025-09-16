# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libcec"
PKG_VERSION="6.0.2"
PKG_SHA256="090696d7a4fb772d7acebbb06f91ab92e025531c7c91824046b9e4e71ecb3377"
PKG_LICENSE="GPL"
PKG_SITE="http://libcec.pulse-eight.com/"
PKG_URL="https://github.com/Pulse-Eight/libcec/archive/libcec-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd p8-platform swig:host"
PKG_LONGDESC="libCEC is an open-source dual licensed library designed for communicating with the Pulse-Eight USB - CEC Adaptor."

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=1 \
                       -DCMAKE_INSTALL_LIBDIR:STRING=lib \
                       -DCMAKE_INSTALL_LIBDIR_NOARCH:STRING=lib \
                       -DSKIP_PYTHON_WRAPPER=1 \
                       -DHAVE_IMX_API=0 \
                       -DHAVE_GIT_BIN=0 \
                       -DHAVE_RPI_LIB=0"

if [ "${KODIPLAYER_DRIVER}" = "libamcodec" ]; then
  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} -DHAVE_AOCEC_API=1"
else
  PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET} -DHAVE_AOCEC_API=0 -DHAVE_AMLOGIC_API=0"
fi

# libX11 and xrandr to read the sink's EDID, used to determine the PC's HDMI physical address
if [ "${DISPLAYSERVER}" = "x11" ]; then
  PKG_DEPENDS_TARGET+=" libX11 libXrandr"
fi

if [ "${CEC_FRAMEWORK_SUPPORT}" = "yes" ]; then
  PKG_CMAKE_OPTS_TARGET+=" -DHAVE_LINUX_API=1"
else
  PKG_CMAKE_OPTS_TARGET+=" -DHAVE_LINUX_API=0"
fi

post_makeinstall_target() {
  # Remove the Python3 demo - useless for us
  rm -f ${INSTALL}/usr/bin/pyCecClient

  # Remove the sysmlink and redirect to /var/lib so that we can change libcec versions at run time
  rm -f ${INSTALL}/usr/lib/libcec.so.6
  ln -sf /var/lib/libcec.so.6 ${INSTALL}/usr/lib/libcec.so.6

	PYTHON_DIR=${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}
  if [ -d ${PYTHON_DIR}/dist-packages ]; then
    mv ${PYTHON_DIR}/dist-packages ${PYTHON_DIR}/site-packages
  fi
}
