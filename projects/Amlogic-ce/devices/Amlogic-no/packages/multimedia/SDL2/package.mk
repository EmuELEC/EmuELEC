# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="SDL2"
PKG_VERSION="2.32.10"
#PKG_SHA256="332cb37d0be20cb9541739c61f79bae5a477427d79ae85e352089afdaf6666e4"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus ${OPENGLES} pulseaudio wayland wayland-protocols libxkbcommon vulkan-loader"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_DEPENDS_HOST="toolchain:host distutilscross:host"
PKG_CMAKE_OPTS_HOST="-DSDL_MALI=OFF -DSDL_KMSDRM=OFF -DSDL_X11=OFF"

PKG_CMAKE_OPTS_TARGET="-DSDL_STATIC=OFF \
                       -DSDL_LIBC=ON \
                       -DSDL_GCC_ATOMICS=ON \
                       -DSDL_ALTIVEC=OFF \
                       -DSDL_OSS=OFF \
                       -DSDL_ALSA=ON \
                       -DSDL_ALSA_SHARED=ON \
                       -DSDL_JACK=OFF \
                       -DSDL_ESD=OFF \
                       -DSDL_ARTS=OFF \
                       -DSDL_NAS=OFF \
                       -DSDL_LIBSAMPLERATE=OFF \
                       -DSDL_SNDIO=OFF \
                       -DSDL_DISKAUDIO=OFF \
                       -DSDL_DUMMYAUDIO=OFF \
                       -DSDL_DUMMYVIDEO=OFF \
                       -DSDL_WAYLAND=ON \
                       -DSDL_COCOA=OFF \
                       -DSDL_DIRECTFB=OFF \
                       -DSDL_VIVANTE=OFF \
                       -DSDL_FUSIONSOUND=OFF \
                       -DSDL_PTHREADS=ON \
                       -DSDL_PTHREADS_SEM=ON \
                       -DSDL_DIRECTX=OFF \
                       -DSDL_CLOCK_GETTIME=OFF \
                       -DSDL_RPATH=OFF \
                       -DSDL_RENDER_D3D=OFF \
                       -DSDL_X11=OFF \
                       -DSDL_OPENGLES=ON \
                       -DSDL_VULKAN=ON \
                       -DSDL_PULSEAUDIO=ON \
                       -DSDL_HIDAPI_JOYSTICK=OFF \
                       -DSDL_KMSDRM=ON \
                       -DSDL_KMSDRM_SHARED=ON \
                       -DSDL_MALI=ON"


post_makeinstall_target() {
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/sdl2-config
  #sed -i 's|Libs: -L${libdir}   -lSDL2|Libs: -L${libdir} -lSDL2 -lm -ldrm -lgbm -lEGL -lGLESv2|' ${SYSROOT_PREFIX}/usr/lib/pkgconfig/sdl2.pc
  safe_remove ${INSTALL}/usr/bin
}
