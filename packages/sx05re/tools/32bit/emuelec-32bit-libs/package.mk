# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-32bit-libs"
PKG_VERSION="8e53ca0df4de3a86f9c7d04952b41f25d3396932"
PKG_SHA256="1a273909baaf10d5abf28dc18bf60d63662113c66d9d6d316ae463253c5c7e8c"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/emuelec/emuelec-32bit-libs"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES}"
PKG_LONGDESC="EmuELEC 32-bit libraries, binaries and cores to use with EmuELEC aarch64"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}
if [[ "${DEVICE}" == "OdroidGoAdvance" ]] || [[ "${DEVICE}" == "GameForce" ]]; then
	cp -rf ${PKG_BUILD}/OdroidGoAdvance/* ${INSTALL}/
	
	if [[ "${DEVICE}" == "GameForce" ]]; then
	   cp -rf ${PKG_BUILD}/GameForce/* ${INSTALL}/
	fi
	cp -rf --remove-destination "$(get_build_dir mali-bifrost)/libmali.so_rk3326_gbm_arm32_r13p0_with_vulkan_and_cl" ${INSTALL}/usr/config/emuelec/lib32/libMali.so	
elif [[ "${DEVICE}" == "Amlogic-ng" ]]; then
    cp -rf ${PKG_BUILD}/Amlogic-ng/* ${INSTALL}/
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/gondul/r12p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.gondul.so
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/dvalin/r12p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.dvalin.so
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/m450/r7p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.m450.so
elif [[ "${DEVICE}" == "Amlogic-ne" ]]; then
    cp -rf ${PKG_BUILD}/Amlogic-ne/* ${INSTALL}/
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/gondul/r25p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.gondul.so
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/dvalin/r25p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.dvalin.so
elif [[ "${DEVICE}" == "Amlogic-old" ]]; then
	cp -rf ${PKG_BUILD}/Amlogic-old/* ${INSTALL}/
    cp -p "$(get_build_dir opengl-meson)/lib/eabihf/m450/r7p0/fbdev/libMali.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.m450.so
elif [[ "${DEVICE}" == "RK356x" ]] || [[ "${DEVICE}" == "OdroidM1" ]]; then
	cp -rf ${PKG_BUILD}/RK356x/* ${INSTALL}/
    cp -rfp --remove-destination "$(get_build_dir mali-bifrost)/lib/arm-linux-gnueabihf/libmali-bifrost-g52-g2p0-gbm.so" ${INSTALL}/usr/config/emuelec/lib32/libMali.so
fi

mkdir -p ${INSTALL}/usr/lib
ln -sf /emuelec/lib32 ${INSTALL}/usr/lib/arm-linux-gnueabihf
ln -sf /emuelec/lib32/ld-linux-armhf.so.3 ${INSTALL}/usr/lib/ld-linux-armhf.so.3

mkdir -p ${INSTALL}/usr/lib/libretro
cp ${PKG_DIR}/infos/*.info ${INSTALL}/usr/lib/libretro/
}
