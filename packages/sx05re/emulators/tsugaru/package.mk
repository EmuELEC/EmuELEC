# SPDX-License-Identifier: GPL-2.0-or-later
# Tsugaru FM Towns emulator - standalone CUI with SDL2 backend (KMSDRM/mali)

PKG_NAME="tsugaru"
PKG_VERSION="0e31cb4065fd5b7888cb6c13d19f358925f9366e"
PKG_ARCH="any"
PKG_LICENSE="BSD-3"
PKG_SITE="https://github.com/captainys/TOWNSEMU"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib"
PKG_LONGDESC="FM Towns emulator Tsugaru, CUI frontend with custom SDL2 video/input backend"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  # Upstream is developed on x86 where 'char' is signed; aarch64 defaults to
  # unsigned char. Match upstream semantics tree-wide.
  export CFLAGS="${CFLAGS} -fsigned-char"
  export CXXFLAGS="${CXXFLAGS} -fsigned-char"

  # CMakeLists lives in src/, not in the repo root
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/src/CMakeLists.txt"
  PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release"

  # Replace the X11/GL fssimplewindow connection with the SDL2 backend
  cp ${PKG_DIR}/files/fssimplewindow_connection.h \
     ${PKG_DIR}/files/fssimplewindow_connection.cpp \
     ${PKG_DIR}/files/CMakeLists.txt \
     ${PKG_BUILD}/src/externals/connect_fssimplewindow/

  # CPU/disc/no-GL patches; abort the build if the source layout changed
  python3 ${PKG_DIR}/files/patch_i486.py ${PKG_BUILD} || die "tsugaru: patch stage failed"
}

make_target() {
  ninja Tsugaru_CUI
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp main_cui/Tsugaru_CUI ${INSTALL}/usr/bin/tsugaru
  cp ${PKG_DIR}/scripts/tsugarustart.sh ${INSTALL}/usr/bin/tsugarustart.sh
  chmod +x ${INSTALL}/usr/bin/tsugarustart.sh
  mkdir -p ${INSTALL}/usr/config/tsugaru
  cp ${PKG_DIR}/config/tsugaru.gptk ${INSTALL}/usr/config/tsugaru/tsugaru.gptk
}