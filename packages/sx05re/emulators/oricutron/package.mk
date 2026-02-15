# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024

PKG_NAME="oricutron"
PKG_VERSION="a76131d"
PKG_REV="1"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://github.com/pete-gordon/oricutron"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="Oricutron - Oric-1/Atmos/Telestrat emulator"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cd "$PKG_BUILD"

  sed -i \
    -e 's/filereq_gtk/filereq_sdl/g;s/msgbox_gtk/msgbox_sdl/g' \
    -e 's/[[:space:]]*\(gui_x11\|render_gl\)\.o//g;/\(gui_x11\|render_gl\)\.c/d' \
    -e 's/-D__OPENGL_AVAILABLE__//g;s/ -l\(GL\|GLU\|X11\)//g;s/-m64//g;s| -L/usr/lib64||g' \
    -e '/pkg-config.*gtk/d;s/^\t\$(CXX)/\t\$(CC)/' \
    -e 's/msgbox_sdl\.o/& emuelec_stub.o/' \
    Makefile

  cat > emuelec_stub.c <<'EOF'
void clipboard_copy(const char *t){(void)t;}
char *clipboard_paste(void){return "";}
void init_gui_native(void){}
void shut_gui_native(void){}
EOF
}

make_target() {
  cd "$PKG_BUILD"

  make PLATFORM=linux CC="$CC" CXX="$CC" \
    CFLAGS="$CFLAGS -I$SYSROOT_PREFIX/usr/include/SDL -D_GNU_SOURCE=1 -D_REENTRANT -DAUDIO_BUFLEN=1024 -D__CBCOPY__ -D__CBPASTE__ -DAPP_NAME_FULL='\"Oricutron\"' -DAPP_YEAR='\"2024\"' -DVERSION_COPYRIGHTS='\"Oricutron (c)2024\"'" \
    LDFLAGS="$LDFLAGS -L$SYSROOT_PREFIX/usr/lib" \
    LIBS="-lSDL -lpthread -lm"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -f ${PKG_BUILD}/oricutron ${INSTALL}/usr/bin/oricutron
  chmod +x ${INSTALL}/usr/bin/oricutron

  cp -f ${PKG_DIR}/scripts/oricutronstart.sh ${INSTALL}/usr/bin/oricutronstart.sh
  chmod +x ${INSTALL}/usr/bin/oricutronstart.sh

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/oricutron
  cp -r ${PKG_BUILD}/roms   ${INSTALL}/usr/config/emuelec/configs/oricutron/ 2>/dev/null || :
  cp -r ${PKG_BUILD}/images ${INSTALL}/usr/config/emuelec/configs/oricutron/ 2>/dev/null || :

  cp -f ${PKG_DIR}/config/oricutron.cfg \
    ${INSTALL}/usr/config/emuelec/configs/oricutron/oricutron.cfg

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/oricutron/disks
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/oricutron/tapes

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/gptokeyb
  cp -f ${PKG_DIR}/config/oricutron.gptk \
    ${INSTALL}/usr/config/emuelec/configs/gptokeyb/oricutron.gptk 2>/dev/null || :
}
