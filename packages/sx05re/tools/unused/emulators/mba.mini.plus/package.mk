# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mba.mini.plus"
PKG_VERSION="0446f417b9434bccf043fb0d2c256303c5bdf2a8"
PKG_SHA256="a5c944857fe549522efa02f96fa495b2d3affa49ff3de3e1f81852f1ff9a4eee"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/shantigilbert/MBA.mini.Plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec"
PKG_SHORTDESC="M.B.A = MAME's skeleton + FBA's romsets"
PKG_LONGDESC="M.B.A-mini from MAME2010-libretro (https://github.com/libretro/mame2010-libretro) after the codes is streamlined, only CPS 1/2, NEOGEO, IREM M92 machines && roms is supported."
PKG_TOOLCHAIN="make"

if [[ "${ARCH}" == "aarch64" ]]; then
PKG_PATCH_DIRS="emuelec-aarch64"
fi

pre_configure_target() {
  
  
  
if [[ "${ARCH}" == "arm" ]]; then
  
   if [[ "${DEVICE}" == "Amlogic-ng" || "${DEVICE}" == "Amlogic-ne" || "${DEVICE}" == "Amlogic-no" ]]; then
	PKG_MAKE_OPTS_TARGET="platform=AMLG12B"
  elif [ "${DEVICE}" = "Amlogic-old" ]; then
	PKG_MAKE_OPTS_TARGET="platform=AMLGX"
  fi
  
  PKG_MAKE_OPTS_TARGET+=" CC=${CC} LD=${CC}"
  
  sed -i -e "s|uname -a|echo armv|" \
         -e "s|uname -m|echo armv|" \
         -e "s|LIBS = -lm|LIBS = |g" \
         -e "s|LIBS = |LIBS = -lm|g" \
    makefile
  
else

  if [[ "${DEVICE}" == "Amlogic-ng" || "${DEVICE}" == "Amlogic-ne" || "${DEVICE}" == "Amlogic-no" ]]; then
	PKG_MAKE_OPTS_TARGET="platform=emuelec-n2"
  elif [ "${DEVICE}" = "Amlogic-old" ]; then
	PKG_MAKE_OPTS_TARGET="platform=emuelec"
  fi
  
  PKG_MAKE_OPTS_TARGET+=" CC=${CC} LD=${CC}"
  
  sed -i -e "s|uname -a|echo aarch64|" \
         -e "s|uname -m|echo aarch64|" \
         -e "s|LIBS = -lm|LIBS = |g" \
         -e "s|LIBS = |LIBS = -lm|g" \
    makefile
fi
}

makeinstall_target() {
 mkdir -p ${INSTALL}/usr/lib/libretro
 cp mba_mini_libretro.so ${INSTALL}/usr/lib/libretro/mba_mini_libretro.so
}
