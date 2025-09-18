# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="advancemame"
PKG_VERSION="d97cdf00fecf8bcdb3b52d4a570c32695ce41f56"
PKG_SHA256="f546df00b88c3f4b4c54e78b6c2cef68f05d6e3766c38416392ad8610014bfbb"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/amadvance/advancemame"
PKG_URL="https://github.com/amadvance/advancemame/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_DIR="advancemame-${PKG_VERSION}*"
PKG_DEPENDS_TARGET="toolchain freetype slang alsa SDL2"
PKG_SECTION="emuelec/mod"
PKG_SHORTDESC="A MAME and MESS port with an advanced video support for Arcade Monitors, TVs, and PC Monitors "
PKG_LONGDESC="A MAME and MESS port with an advanced video support for Arcade Monitors, TVs, and PC Monitors "
PKG_IS_ADDON="no"
PKG_AUTORECONF="yes"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-parallel"

pre_configure_target() {
export CFLAGS=`echo ${CFLAGS} | sed -e "s|-O.|-O3|g"`
sed -i "s|#include <slang.h>|#include <${SYSROOT_PREFIX}/usr/include/slang.h>|" ${PKG_BUILD}/configure.ac
}

pre_make_target() {
VERSION="EmuELEC-v$(cat ${ROOT}/packages/sx05re/emuelec/config/EE_VERSION)-${PKG_VERSION:0:7}"
echo ${VERSION} > ${PKG_BUILD}/.version
}

make_target() {
cd ${PKG_BUILD}
./autogen.sh
./configure --prefix=/usr --datadir=/usr/share/ --datarootdir=/usr/share/ --host=${TARGET_NAME} --enable-fb --enable-freetype --with-freetype-prefix=${SYSROOT_PREFIX}/usr/ --enable-slang
make mame
make j
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/config/emuelec/configs/advmame
mkdir -p ${INSTALL}/usr/bin

if [ "${DEVICE}" == "OdroidGoAdvance" ]; then
   cp -r ${PKG_DIR}/config/advmame.rc_oga ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
elif [ "${DEVICE}" == "GameForce" ]; then
   cp -r ${PKG_DIR}/config/advmame.rc_gf ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
else
   cp -r ${PKG_DIR}/config/advmame.rc ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
fi

cp -r ${PKG_DIR}/bin/* ${INSTALL}/usr/bin
chmod +x ${INSTALL}/usr/bin/*

cp -r ${PKG_BUILD}/obj/mame/linux/blend/advmame ${INSTALL}/usr/bin
cp -r ${PKG_BUILD}/obj/j/linux/blend/advj ${INSTALL}/usr/bin
cp -r ${PKG_BUILD}/support/category.ini ${INSTALL}/usr/config/emuelec/configs/advmame
cp -r ${PKG_BUILD}/support/sysinfo.dat ${INSTALL}/usr/config/emuelec/configs/advmame
cp -r ${PKG_BUILD}/support/history.dat ${INSTALL}/usr/config/emuelec/configs/advmame
cp -r ${PKG_BUILD}/support/hiscore.dat ${INSTALL}/usr/config/emuelec/configs/advmame
cp -r ${PKG_BUILD}/support/event.dat ${INSTALL}/usr/config/emuelec/configs/advmame
}
