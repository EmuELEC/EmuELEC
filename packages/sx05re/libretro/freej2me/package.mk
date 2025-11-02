# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="freej2me"
PKG_VERSION="8b9bc8a19baf26e3d92f88934a64a32f1cbc2795"
PKG_SHA256="cec467023fed435e10fdb64147d962717aa81c0e43170c22cdebeeddcd7e21db"
PKG_ARCH="any"
PKG_SITE="https://github.com/hex007/freej2me"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng apache-ant:host"
PKG_SHORTDESC="A free J2ME emulator with libretro, awt and sdl2 frontends."
PKG_TOOLCHAIN="make"

pre_configure_target() {
${TOOLCHAIN}/bin/ant
}

make_target(){

## SDL2 is not needed for the libretro core and .jar files
## but in case you need it, here are the commands

#sed -i "s|g++|${CXX}|g" ${PKG_BUILD}/src/sdl2/Makefile
#PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src/sdl2"
#make ${PKG_MAKE_OPTS_TARGET}
#mkdir -p ${INSTALL}/usr/bin
#cp ${PKG_BUILD}/src/sdl2/sdl_interface ${INSTALL}/usr/bin

PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src/libretro"
make ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp `find . -name "freej2me_libretro.so" | xargs echo` ${INSTALL}/usr/lib/libretro
    cp ${PKG_BUILD}/build/freej2me-lr.jar ${INSTALL}/usr/lib/libretro
  
  mkdir -p ${INSTALL}/usr/bin
	cp ${PKG_DIR}/scripts/*.sh ${INSTALL}/usr/bin
} 
