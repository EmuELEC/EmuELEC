# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 351ELEC
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="yabasanshiroSA_1_11"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/sydarn/yabause"
PKG_URL="${PKG_SITE}.git"
PKG_VERSION="a40dace1ae0af3ebd45848549fdf396f40e3930f"
PKG_GIT_CLONE_BRANCH="pi4-update"
PKG_ARCH="aarch64"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft zlib"
PKG_LONGDESC="Yabause   is a Sega Saturn emulator and took over as  Yaba Sanshiro"
PKG_TOOLCHAIN="cmake-make"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="+speed"

post_unpack() {
  # use host versions
  sed -i "s|COMMAND m68kmake|COMMAND ${PKG_BUILD}/m68kmake_host|" ${PKG_BUILD}/yabause/src/musashi/CMakeLists.txt
  sed -i "s|COMMAND ./bin2c|COMMAND ${PKG_BUILD}/bin2c_host|" ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
}

pre_make_target() {
  # runs on host so make them manually if package is not crosscompile friendly
  ${HOST_CC} ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/resources/bin2c.c -o ${PKG_BUILD}/bin2c_host
  ${HOST_CC} ${PKG_BUILD}/yabause/src/musashi/m68kmake.c -o ${PKG_BUILD}/m68kmake_host
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="${PKG_BUILD}/yabause "

  #PKG_CMAKE_OPTS_TARGET+=" -DUSE_EGL=OFF -DUSE_OPENGL=ON"
 

  case ${ARCH} in
    aarch64)
      PKG_CMAKE_OPTS_TARGET+=" -DYAB_WANT_ARM7=OFF \
                               -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                               -DCMAKE_TOOLCHAIN_FILE=${PKG_BUILD}/yabause/src/retro_arena/n2.cmake \
                               -DYAB_PORTS=retro_arena"
    ;;
  esac

  #PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_SYSTEM_PROCESSOR=x86_64"

  PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                           -DOPENGL_opengl_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                           -DOPENGL_glx_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                           -DLIBPNG_LIB_DIR=${SYSROOT_PREFIX}/usr/lib \
                           -Dpng_STATIC_LIBRARIES=${SYSROOT_PREFIX}/usr/lib/libpng16.so \
                           -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -a ${PKG_BUILD}/src/retro_arena/yabasanshiro ${INSTALL}/usr/bin
cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

mkdir -p ${INSTALL}/usr/config/emuelec/configs/yabasanshiro
cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/yabasanshiro
} 
