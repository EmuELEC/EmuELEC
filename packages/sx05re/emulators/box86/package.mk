# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="box86"
PKG_VERSION="b197194e2de3ec1f67dd4c5736b8fd479be4cd93"
PKG_SHA256="2a98ce28d2d78047cb2d2be12f98d2eb6a9eb33a7f34bb24852ce91942ff3d7a"
PKG_REV="1"
PKG_ARCH="arm"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box86"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC="Box86 - Linux Userspace x86 Emulator with a twist, targeted at ARM Linux devices"
PKG_TOOLCHAIN="cmake"

if [[ "${DEVICE}" == "Amlogic"* ]]; then
	PKG_CMAKE_OPTS_TARGET=" -DRK3399=ON -DCMAKE_BUILD_TYPE=Release"
else
	PKG_CMAKE_OPTS_TARGET=" -DGOA_CLONE=ON -DCMAKE_BUILD_TYPE=Release"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/emuelec/bin/box86/lib
  cp ${PKG_BUILD}/x86lib/* ${INSTALL}/usr/config/emuelec/bin/box86/lib
  cp ${PKG_BUILD}/.${TARGET_NAME}/box86 ${INSTALL}/usr/config/emuelec/bin/box86/
  
  mkdir -p ${INSTALL}/etc/binfmt.d
  ln -sf /emuelec/configs/box86.conf ${INSTALL}/etc/binfmt.d/box86.conf
 
}
