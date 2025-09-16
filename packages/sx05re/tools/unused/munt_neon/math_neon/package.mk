# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present asakous (https://github.com/asakous)

PKG_NAME="math_neon"
PKG_VERSION="bc25cd6715796c2c656dca9244f042b79c6bac8c"
PKG_ARCH="arm"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/asakous/math_neon"
PKG_URL="https://github.com/asakous/math_neon.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="This project implements the cmath functions and some optimised matrix functions with the aim of increasing the floating point performance of ARM Cortex A-8 based platforms. As well as implementing the functions in ARM NEON assembly, they sacrifice error checking and some accuracy to achieve better performance"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"


PKG_MAKE_OPTS_TARGET="all"

pre_configure_target() {
if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
sed -i -e "s/cortex-a7/cortex-a35/" ${PKG_BUILD}/Makefile
else
sed -i -e "s/cortex-a7/cortex-a53/" ${PKG_BUILD}/Makefile
fi
}
    
makeinstall_target() {
cd ${PKG_BUILD}
cp -f ${PKG_BUILD}/libmathneon.a ${SYSROOT_PREFIX}/usr/lib/
}
