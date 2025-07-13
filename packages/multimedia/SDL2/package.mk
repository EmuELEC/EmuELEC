# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="SDL2"
PKG_VERSION="2.28.5"
PKG_SHA256="332cb37d0be20cb9541739c61f79bae5a477427d79ae85e352089afdaf6666e4"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus ${OPENGLES} pulseaudio"
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
                       -DSDL_JACK_SHARED=OFF \
                       -DSDL_ESD=OFF \
                       -DSDL_ESD_SHARED=OFF \
                       -DSDL_ARTS=OFF \
                       -DSDL_ARTS_SHARED=OFF \
                       -DSDL_NAS=OFF \
                       -DSDL_NAS_SHARED=OFF \
                       -DSDL_LIBSAMPLERATE=OFF \
                       -DSDL_LIBSAMPLERATE_SHARED=OFF \
                       -DSDL_SNDIO=OFF \
                       -DSDL_DISKAUDIO=OFF \
                       -DSDL_DUMMYAUDIO=OFF \
                       -DSDL_DUMMYVIDEO=OFF \
                       -DSDL_WAYLAND=OFF \
                       -DSDL_WAYLAND_QT_TOUCH=ON \
                       -DSDL_WAYLAND_SHARED=OFF \
                       -DSDL_COCOA=OFF \
                       -DSDL_DIRECTFB=OFF \
                       -DSDL_VIVANTE=OFF \
                       -DSDL_DIRECTFB_SHARED=OFF \
                       -DSDL_FUSIONSOUND=OFF \
                       -DSDL_FUSIONSOUND_SHARED=OFF \
                       -DSDL_PTHREADS=ON \
                       -DSDL_PTHREADS_SEM=ON \
                       -DSDL_DIRECTX=OFF \
                       -DSDL_CLOCK_GETTIME=OFF \
                       -DSDL_RPATH=OFF \
                       -DSDL_RENDER_D3D=OFF \
                       -DSDL_X11=OFF \
                       -DSDL_OPENGLES=ON \
                       -DSDL_VULKAN=OFF \
                       -DSDL_PULSEAUDIO=ON \
                       -DSDL_HIDAPI_JOYSTICK=OFF"

case "${DEVICE}" in
  'Amlogic-ng'|'Amlogic-old')  # We should've used PROJECT=Amlogic-ce logically, but using these two device names here saves a comparasion (only device needs to be compared)
    PKG_PATCH_DIRS="Amlogic"
    PKG_CMAKE_OPTS_TARGET+=" -DSDL_MALI=ON -DSDL_KMSDRM=OFF"
  ;;
  'OdroidGoAdvance'|'GameForce'|'RK356x'|'OdroidM1')
    PKG_PATCH_DIRS="Rockchip"
    PKG_CMAKE_OPTS_TARGET+=" -DSDL_KMSDRM=ON"
    PKG_DEPENDS_TARGET+=" libdrm mali-bifrost"
    if [ "${DEVICE}" = "OdroidGoAdvance" ]; then
      PKG_PATCH_DIRS+=" OdroidGoAdvance"
      PKG_DEPENDS_TARGET+=" librga"
      # This is evil, but we save multiple comparasions
      pre_make_host() {
        sed -i "s| -lrga||g" ${PKG_BUILD}/CMakeLists.txt
      }
      pre_make_target() {
        if ! `grep -rnw "${PKG_BUILD}/CMakeLists.txt" -e '-lrga'`; then
          sed -i "s|--no-undefined|--no-undefined -lrga|" ${PKG_BUILD}/CMakeLists.txt
        fi
      }
    fi
  ;;
esac


post_makeinstall_target() {
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/sdl2-config
  safe_remove ${INSTALL}/usr/bin
}
