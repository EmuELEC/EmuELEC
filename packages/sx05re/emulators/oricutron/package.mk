# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC Contributors

PKG_NAME="oricutron"
PKG_VERSION="a76131d"
PKG_ARCH="aarch64 arm"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/pete-gordon/oricutron"
PKG_URL="https://github.com/pete-gordon/oricutron/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Oricutron - Oric Atmos emulator"
PKG_LONGDESC="Oricutron is an accurate emulator for the Oric Atmos computer."
PKG_TOOLCHAIN="make"

make_target() {
  # Remove -m32 flag for aarch64 builds (incompatible with ARM)
  sed -i 's/-m32//g' ${PKG_BUILD}/Makefile

  # EmuELEC target SDL is built without X11 WM backend, so gui_x11.c can't compile here.
  # Keep Linux build path, but swap only native GUI helper and remove hard X11 link flag.
  sed -i 's/CUSTOMOBJS = gui_x11.o/CUSTOMOBJS = gui_stub.o/' ${PKG_BUILD}/Makefile
  sed -i 's/ -lX11//g' ${PKG_BUILD}/Makefile
  # Also remove -lGL — EmuELEC uses GLES, desktop GL is not in sysroot
  sed -i 's/ -lGL//g' ${PKG_BUILD}/Makefile

  cat > ${PKG_BUILD}/gui_stub.c << 'EOF'
#include "system.h"
#include "6502.h"
#include "via.h"
#include "8912.h"
#include "gui.h"
#include "disk.h"
#include "monitor.h"
#include "6551.h"
#include "machine.h"

SDL_bool init_gui_native(struct machine *oric)
{
  return SDL_TRUE;
}

void shut_gui_native(struct machine *oric)
{
}

void gui_open_url(const char* url)
{
}

SDL_bool clipboard_copy(struct machine *oric)
{
  return SDL_FALSE;
}

SDL_bool clipboard_paste(struct machine *oric)
{
  return SDL_FALSE;
}
EOF
  
  make -C ${PKG_BUILD} PLATFORM=linux NOGTK=1 \
    CC="${CC}" \
    CXX="${CC}" \
    CFLAGS="${CFLAGS} -I${SYSROOT_PREFIX}/usr/include/SDL -D_GNU_SOURCE=1 -D_REENTRANT -DAUDIO_BUFLEN=1024 -D__CBCOPY__ -D__CBPASTE__ -DAPP_NAME_FULL='\"Oricutron\"' -DAPP_YEAR='\"2024\"' -DVERSION_COPYRIGHTS='\"Oricutron (c)2024\"'" \
    LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib" \
    LIBS="-lSDL -lpthread -lm"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/oricutron ${INSTALL}/usr/bin/
}
