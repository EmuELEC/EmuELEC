# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-retroarch"
PKG_VERSION="$(get_pkg_version retroarch)"
PKG_NEED_UNPACK="$(get_pkg_directory retroarch)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL=""
PKG_LICENSE="GPLv3"
#PKG_DEPENDS_TARGET="retroarch lib32-zlib lib32-${OPENGLES}"
PKG_DEPENDS_TARGET="retroarch lib32-toolchain lib32-SDL2 lib32-alsa-lib lib32-openssl lib32-freetype lib32-zlib lib32-ffmpeg lib32-libass lib32-${OPENGLES}"
# samba avahi nss-mdns  openal-soft
PKG_LONGDESC="Reference frontend for the libretro API."
PKG_BUILD_FLAGS="lib32"

RA_DIRECTORY="$(get_pkg_directory retroarch)"
PKG_PATCH_DIRS+=" ${RA_DIRECTORY}/patches" 

PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                           --enable-alsa \
                           --enable-udev \
                           --disable-opengl1 \
                           --disable-opengl \
                           --enable-egl \
                           --enable-opengles \
                           --disable-wayland \
                           --disable-x11 \
                           --enable-zlib \
                           --enable-freetype \
                           --disable-discord \
                           --disable-vg \
                           --disable-sdl \
                           --enable-sdl2 \
                           --enable-ffmpeg \
                           --enable-neon"

if [ "${PROJECT}" = "Amlogic-ce" ]; then
  PKG_PATCH_DIRS+=" ${RA_DIRECTORY}/patches/Amlogic"
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-kms \
                           --enable-mali_fbdev"
elif [[ "${DEVICE}" =~ ^(OdroidGoAdvance|GameForce|RK356x|OdroidM1)$ ]]; then
  PKG_RKMISC="yes"
  PKG_DEPENDS_TARGET+=" lib32-libdrm lib32-librga"
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3 \
                           --enable-opengles3_2 \
                           --enable-kms \
                           --disable-mali_fbdev"
  if [ "${DEVICE}" = "OdroidGoAdvance" ]; then
    PKG_PATCH_DIRS+=" ${RA_DIRECTORY}/patches/OdroidGoAdvance"
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-odroidgo2"
  elif [ "${DEVICE}" = "GameForce" ]; then
    PKG_PATCH_DIRS+=" ${RA_DIRECTORY}/patches/OdroidGoAdvance"
  fi
else
  echo "${PKG_NAME}: Unsupported devices ${DEVICE} when only AmlNG, AmlOld, OGA, GF, RK356X, M1 is supported" 1>&2
  false
fi

if [ "${PULSEAUDIO_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" lib32-libpulse"
fi

unpack() {
  ${SCRIPTS}/get retroarch
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/retroarch/retroarch-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

pre_configure_target() {
# Retroarch does not like -O3 for CHD loading with cheevos
  export CFLAGS="${CFLAGS} -O3 -fno-tree-vectorize"
  TARGET_CONFIGURE_OPTS=""
  cd ${PKG_BUILD}
}

make_target() {
	make HAVE_UPDATE_ASSETS=1 HAVE_LIBRETRODB=1 HAVE_BLUETOOTH=1 HAVE_NETWORKING=1 HAVE_LAKKA=1 HAVE_ZARCH=1 HAVE_QT=0 HAVE_LANGEXTRA=1 HAVE_LAKKA_PROJECT=0 HAVE_LAKKA_SERVER=0
  [ $? -eq 0 ] && echo "(retroarch ok)" || { echo "(retroarch failed)" ; exit 1 ; }
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  #patchelf --set-interpreter /usr/lib32/ld-linux-armhf.so.3 ${PKG_BUILD}/retroarch
  cp ${PKG_BUILD}/retroarch ${INSTALL}/usr/bin/retroarch32
}
