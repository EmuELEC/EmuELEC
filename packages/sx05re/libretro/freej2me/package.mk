# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="freej2me"
PKG_VERSION="d8aa5d9a55a5673b77d5999342143ebdf131bfbd"
PKG_SHA256="98fb61841ff6939dff091f88e6f332d9d9b8ce9801d3a1919ee16f3a3f747ffb"
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
