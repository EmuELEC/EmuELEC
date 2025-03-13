# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="openbor"
PKG_VERSION="b2111a911ae64045803ed6f6371c9fccfbea9693"
PKG_SHA256="2aa948c1193e35bf4d85ff9862b02ef7fedbc39df2157138fd21061ff4ec22b1"
PKG_ARCH="any"
PKG_SITE="https://github.com/DCurrent/openbor"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng openborff"
PKG_SHORTDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more! "
PKG_LONGDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more! "
PKG_TOOLCHAIN="make"

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
PKG_PATCH_DIRS="OdroidGoAdvance"
fi


if [[ "${ARCH}" == "arm" ]]; then
	PKG_PATCH_DIRS="${ARCH}"
else
	PKG_PATCH_DIRS="emuelec-aarch64"
fi


pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="BUILD_LINUX_${ARCH}=1 \
                        -C ${PKG_BUILD}/engine \
                        SDKPATH="${SYSROOT_PREFIX}"
                        PREFIX=${TARGET_NAME}"
}

pre_make_target() {
cd ${PKG_BUILD}/engine
chmod +x ./version.sh
./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp `find . -name "OpenBOR.elf" | xargs echo` ${INSTALL}/usr/bin/OpenBOR
    cp ${PKG_DIR}/scripts/*.sh ${INSTALL}/usr/bin
    chmod +x ${INSTALL}/usr/bin/*

    mkdir -p ${INSTALL}/usr/config/emuelec/configs/openbor
		cp ${PKG_DIR}/config/master.cfg ${INSTALL}/usr/config/emuelec/configs/openbor/master.cfg

		mkdir -p ${INSTALL}/usr/config/emuelec/configs/gptokeyb
		cp -rf ${PKG_DIR}/config/gptokeyb/* ${INSTALL}/usr/config/emuelec/configs/gptokeyb
   } 
