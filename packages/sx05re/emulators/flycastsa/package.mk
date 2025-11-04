# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="flycastsa"
PKG_VERSION="bf2bd7efed41e9f3367a764c2d90fcaa9c38a1f9"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} alsa SDL2 libzip zip"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="master"


if [ "${ARCH}" == "arm" ]; then
	PKG_PATCH_DIRS="arm"
fi

pre_configure_target() {
export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds"
PKG_CMAKE_OPTS_TARGET+="-DUSE_GLES=ON -DUSE_VULKAN=OFF -DUSE_HOST_SDL=ON"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/flycast ${INSTALL}/usr/bin/flycast
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

	chmod +x ${INSTALL}/usr/bin/flycast.sh
	chmod +x ${INSTALL}/usr/bin/set_flycast_joy.sh
}
