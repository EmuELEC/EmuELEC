# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-bennugd-monolithic"
PKG_VERSION="$(get_pkg_version bennugd-monolithic)"
PKG_NEED_UNPACK="$(get_pkg_directory bennugd-monolithic)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/christianhaitian/bennugd-monolithic"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libvorbisidec lib32-SDL2 lib32-SDL2_mixer lib32-libpng lib32-tre"
PKG_PATCH_DIRS+=" $(get_pkg_directory bennugd-monolithic)/patches" 
PKG_SHORTDESC="Use for executing bennugd games like Streets of Rage Remake "
PKG_TOOLCHAIN="cmake-make"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get bennugd-monolithic
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/bennugd-monolithic/bennugd-monolithic-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

pre_configure_target() {
  chainfile="cmake-${TARGET_NAME}.conf"

  PKG_CMAKE_SCRIPT="${PKG_BUILD}/projects/cmake/bgdc/CMakeLists.txt"
  cd ${PKG_BUILD}/projects/cmake/bgdc/
  cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN}/etc/${chainfile} -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel ${PKG_CMAKE_SCRIPT}
  make

  PKG_CMAKE_SCRIPT="${PKG_BUILD}/projects/cmake/bgdi/CMakeLists.txt"
  cd ${PKG_BUILD}/projects/cmake/bgdi/
  cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN}/etc/${chainfile} -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel ${PKG_CMAKE_SCRIPT}
  make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/projects/cmake/bgdi/bgdi ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/projects/cmake/bgdc/bgdc ${INSTALL}/usr/bin
} 
