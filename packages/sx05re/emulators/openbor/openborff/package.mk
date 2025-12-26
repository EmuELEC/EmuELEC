# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="openborff"
PKG_VERSION="3c14ffc37c984a5aebc7a3fb6133b47484d43bd2"
PKG_SHA256="275ba0593027053cfd9df0586868e1471b71153858dc0b42429938db07eba74c"
PKG_ARCH="any"
PKG_SITE="https://github.com/gonzalomvp/openbor"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng"
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
                        SDKPATH=\"${SYSROOT_PREFIX}\" \
                        PREFIX=${TARGET_NAME}"
}

pre_make_target() {
cd ${PKG_BUILD}/engine
./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp `find . -name "OpenBOR.elf" | xargs echo` ${INSTALL}/usr/bin/OpenBORff
    chmod +x ${INSTALL}/usr/bin/*
    mkdir -p ${INSTALL}/usr/config/emuelec/configs/openbor
	cp ${PKG_DIR}/config/master.cfg ${INSTALL}/usr/config/emuelec/configs/openbor/masterff.cfg
   } 
