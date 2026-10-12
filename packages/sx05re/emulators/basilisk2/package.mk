# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present EmuELEC (https://github.com/emuelec)

PKG_NAME="basilisk2"
PKG_VERSION="892eeb74ab9d70dfb034138a0b39057b14f275bc"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/kanjitalk755/macemu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Basilisk II, an open source 68k Macintosh emulator"
PKG_TOOLCHAIN="manual"

configure_target() {
  cd ${PKG_BUILD}/BasiliskII/src/Unix
  NO_CONFIGURE=1 ./autogen.sh

  # cross compiling: runtime checks cannot run, results for aarch64 Linux/glibc
  export ac_cv_mmap_anon=yes \
         ac_cv_mmap_anonymous=yes \
         ac_cv_mprotect_works=yes \
         ac_cv_signal_need_reinstall=no \
         ac_cv_sigaction_need_reinstall=no \
         ac_cv_have_extended_signals=yes \
         ac_cv_have_skip_instruction=yes

  ./configure --host=${TARGET_NAME} \
              --build=${HOST_NAME} \
              --enable-sdl-video \
              --enable-sdl-audio \
              --enable-vosf \
              --enable-jit-compiler=no \
              --enable-fpe=uae \
              --disable-xf86-dga \
              --disable-xf86-vidmode \
              --disable-fbdev-dga \
              --without-x \
              --without-gtk \
              --without-mon \
              --without-esd
}

make_target() {
  cd ${PKG_BUILD}/BasiliskII/src/Unix
  make CC_FOR_BUILD="${HOST_CC}" CXX_FOR_BUILD="${HOST_CXX}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/BasiliskII/src/Unix/BasiliskII ${INSTALL}/usr/bin/
  cp ${PKG_DIR}/scripts/basilisk2start.sh ${INSTALL}/usr/bin/
  chmod +x ${INSTALL}/usr/bin/basilisk2start.sh

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/basilisk2/gptk
  cp ${PKG_DIR}/config/basilisk2.prefs ${INSTALL}/usr/config/emuelec/configs/basilisk2/
  cp ${PKG_DIR}/config/basilisk2.gptk ${INSTALL}/usr/config/emuelec/configs/basilisk2/gptk/
}
