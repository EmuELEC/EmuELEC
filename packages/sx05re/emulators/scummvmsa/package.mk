# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="scummvmsa"
PKG_VERSION="ae848a551e9a0a68621bc4c3786468f836299f79"
PKG_SHA256="a265341667dac08696067f7735a3e9f9874948b46b0c04000bfd9bf170afed42"
PKG_REV="1"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/scummvm/scummvm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_net freetype fluidsynth-git libmad"
PKG_SHORTDESC="Script Creation Utility for Maniac Mansion Virtual Machine"
PKG_LONGDESC="ScummVM is a program which allows you to run certain classic graphical point-and-click adventure games, provided you already have their data files."

pre_configure_target() {
  cd ${PKG_BUILD}

  TARGET_CONFIGURE_OPTS="--disable-opengl-game \
                         --disable-opengl-game-classic \
                         --disable-opengl-game-shaders \
                         --host=${TARGET_NAME} \
                         --backend=sdl \
                         --enable-vkeybd \
                         --enable-optimizations \
                         --opengl-mode=gles2 \
                         --with-sdl-prefix=${SYSROOT_PREFIX}/usr \
                         --disable-debug \
                         --enable-release \
                         --enable-engine=xeen \
                         --enable-engine=mm \
                         --prefix=/usr/local"
}

configure_target() {
  cd ${PKG_BUILD}
  
  ./configure ${TARGET_CONFIGURE_OPTS}
}

make_target() {
  cd ${PKG_BUILD}
  
  make ${PKG_MAKE_OPTS_TARGET} V=1
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/scummvm/extra 
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/scummvm/
  cp -rf ${PKG_BUILD}/backends/vkeybd/packs/*.zip ${INSTALL}/usr/config/scummvm/extra
  mv ${INSTALL}/usr/local/bin ${INSTALL}/usr/
  cp -rf ${PKG_DIR}/bin/* ${INSTALL}/usr/bin
  
  for i in metainfo pixmaps appdata applications doc icons man; do
    rm -rf "${INSTALL}/usr/local/share/${i}"
  done
}
