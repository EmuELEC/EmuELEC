# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="timidity"
PKG_VERSION="2.15.0"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE="https://sourceforge.net/projects/timidity/"
PKG_URL="${SOURCEFORGE_SRC}/timidity/TiMidity++-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer"
PKG_LONGDESC="TiMidity++"
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
  # doesn't like to be build in target folder
  cd ${PKG_BUILD}
  rm -fr .${TARGET_NAME}

  # simple tool can be build directly
  ${HOST_CC} timidity/calcnewt.c -o timidity/calcnewt_host -lm

  PKG_CONFIGURE_OPTS_TARGET="--host=${TARGET_NAME} \
                             --enable-alsa
			     --with-default-output=alsa \
                             --with-default-path=/storage/.config/timidity \
                             lib_cv_va_copy=yes \
                             lib_cv___va_copy=yes \
                             lib_cv_va_val_copy=no \
                             ac_cv_c_bigendian=no \
                             --with-includes=${SYSROOT_PREFIX}/usr/include \
                             --with-libraries=${SYSROOT_PREFIX}/usr/lib
			     --enable-alsaseq"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/timidity
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/timidity
  ln -sf /storage/roms/bios/timidity/freepats ${INSTALL}/usr/config/timidity/freepats
  
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/timidity/timidity ${INSTALL}/usr/bin
  
  mkdir -p ${INSTALL}/etc/timidity/
  ln -sf /storage/.config/timidity/freepats.cfg ${INSTALL}/etc/timidity/freepats.cfg 
}
