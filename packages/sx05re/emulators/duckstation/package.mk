# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="duckstation"
PKG_VERSION="fd3507c16d098fb32806c281caaefb205946da8a"
#PKG_VERSION="35f272b336667cffd35d149d9da6f85e958ddfa2"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 nasm:host ${OPENGLES} libevdev"
PKG_SECTION="libretro"
PKG_SHORTDESC="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64 "
PKG_TOOLCHAIN="cmake"

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	EXTRA_OPTS+=" -DUSE_DRMKMS=ON -DUSE_FBDEV=OFF -DUSE_MALI=OFF"
else
	EXTRA_OPTS+=" -DUSE_DRMKMS=OFF -DUSE_FBDEV=ON -DUSE_MALI=ON"
fi

pre_configure_target() {
	PKG_CMAKE_OPTS_TARGET+=" -DANDROID=OFF \
	                         -DENABLE_DISCORD_PRESENCE=OFF \
	                         -DUSE_X11=OFF \
                                 -DBUILD_LIBRETRO_CORE=OFF \
				 -DBUILD_GO2_FRONTEND=OFF \
	                         -DBUILD_QT_FRONTEND=OFF \
	                         -DBUILD_NOGUI_FRONTEND=ON \
	                         -DCMAKE_BUILD_TYPE=Release \
	                         -DBUILD_SHARED_LIBS=OFF \
	                         -DUSE_SDL2=ON \
	                         -DENABLE_CHEEVOS=ON \
	                         -DHAVE_EGL=ON \
	                         ${EXTRA_OPTS}"

if [ "${DEVICE}" == "Amlogic-old" ]; then
	cp -rf $(get_build_dir libevdev)/include/linux/linux/input-event-codes.h ${SYSROOT_PREFIX}/usr/include/linux/
fi

}

post_make_target() {
if [ "${DEVICE}" == "Amlogic-old" ]; then
  rm ${SYSROOT_PREFIX}/usr/include/linux/input-event-codes.h
fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/duckstation-nogui ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/duckstation
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/* ${INSTALL}/usr/config/emuelec/configs/duckstation
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/duckstation
  
  rm -rf ${INSTALL}/usr/config/emuelec/configs/duckstation/duckstation-nogui
  rm -rf ${INSTALL}/usr/config/emuelec/configs/duckstation/common-tests
}
