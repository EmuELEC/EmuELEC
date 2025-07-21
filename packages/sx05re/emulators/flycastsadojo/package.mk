#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present DiegroSan (https://github.com/Diegrosan)
#
#NOTE: IT WILL ONLY BE COMPILED IN THE SECOND DENTATIVE, BUT IT IS IMPORTANT THAT IT WILL BE COMPILED, UNTIL THE NEXT PACKAGE UPDATES.
#
#

PKG_NAME="flycastsadojo"
PKG_VERSION="f5dea9e" #6.53+
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/blueminder/flycast-dojo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} alsa SDL2 libzip zip asio vksdl "
PKG_LONGDESC="flycast-dojo is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="master"


if [ "${ARCH}" == "arm" ]; then
    PKG_PATCH_DIRS="arm"
fi

post_unpack() {
  ( cd "${PKG_BUILD}" && git submodule update --init --recursive )
}

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds -Wswitch -Wsign-compare -I$(get_install_dir asio)/usr/include"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLES=ON -DUSE_VULKAN=OFF -DUSE_HOST_SDL=ON -DENABLE_CTEST=OFF -DTEST_AUTOMATION=OFF -DASAN=OFF "
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/flycast-dojo
  
  cp -r ${PKG_DIR}/config/* ${INSTALL}/usr/config/flycast-dojo
  
  cp "${PKG_BUILD}/.${TARGET_NAME}/flycast-dojo" "${INSTALL}/usr/bin/flycastdojo"
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/flycastdojo.sh

}
