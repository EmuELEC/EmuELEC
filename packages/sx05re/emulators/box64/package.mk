# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="box64"
PKG_VERSION="448ee01f44b0aabb5c39d5c73edf8f8b6a051fe4"

# amlogic-old uses older linux headers not compatible with newer versions
[ "${DEVICE}" == "Amlogic-old" ] && PKG_VERSION="6392550208eadf07419692920acc2955bb844af7"

PKG_REV="1"
PKG_ARCH="aarch64"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC="Box64 - Linux Userspace x86_64 Emulator with a twist, targeted at ARM64 Linux devices"
PKG_TOOLCHAIN="cmake"

if [[ "${DEVICE}" == "Amlogic"* ]]; then
	PKG_CMAKE_OPTS_TARGET=" -DODROIDN2=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo"
else
	PKG_CMAKE_OPTS_TARGET=" -DRK3326=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo"
fi

pre_configure_target() {
# https://github.com/ptitSeb/box64/issues/256
if ! grep -q "as-needed" ${PKG_BUILD}/CMakeLists.txt; then
	sed -i "s|as-need|as-needed|g" ${PKG_BUILD}/CMakeLists.txt
fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/emuelec/bin/box64/lib
  cp ${PKG_BUILD}/x64lib/* ${INSTALL}/usr/config/emuelec/bin/box64/lib
  cp ${PKG_BUILD}/.${TARGET_NAME}/box64 ${INSTALL}/usr/config/emuelec/bin/box64/
  
  mkdir -p ${INSTALL}/etc/binfmt.d
  ln -sf /emuelec/configs/box64.conf ${INSTALL}/etc/binfmt.d/box64.conf
 
}
