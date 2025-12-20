# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present DiegroSan (https://github.com/Diegrosan)

PKG_NAME="flycast-dojo"
PKG_VERSION="d0e47e572b1e7b355e88bda8308c89d0c5156cbf" #6.53+
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/blueminder/flycast-dojo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} alsa SDL2 libzip zip asio vksdl "
PKG_LONGDESC="flycast-dojo is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="master"

PKG_CMAKE_OPTS_TARGET+=" -DTHREAD_SANITIZER_AVAILABLE_EXITCODE=1"
PKG_CMAKE_OPTS_TARGET+=" -DADDRESS_SANITIZER_AVAILABLE_EXITCODE=1"
PKG_CMAKE_OPTS_TARGET+=" -DALL_SANITIZERS_AVAILABLE_EXITCODE=1"
PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLES=ON -DUSE_VULKAN=OFF -DUSE_HOST_SDL=ON -DENABLE_CTEST=OFF -DTEST_AUTOMATION=OFF -DASAN=OFF "

if [ "${ARCH}" == "arm" ]; then
    PKG_PATCH_DIRS="arm"
fi

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds -Wswitch -Wsign-compare -I$(get_install_dir asio)/usr/include"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/flycast-dojo
  
  cp -r ${PKG_DIR}/config/* ${INSTALL}/usr/config/flycast-dojo
  
  cp "${PKG_BUILD}/.${TARGET_NAME}/flycast-dojo" "${INSTALL}/usr/bin/flycastdojo"
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/flycastdojo.sh

}
