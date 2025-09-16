# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="dosbox-pure"
PKG_VERSION="a1c81ef494d2ac7a136b330edecbe855fb38b18a"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/schellingb/dosbox-pure"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain linux glibc glib systemd dbus alsa-lib SDL2 SDL2_net SDL_sound libpng zlib libvorbis flac libogg fluidsynth-git munt opusfile"
PKG_LONGDESC="DOSBox Pure is a new fork of DOSBox built for RetroArch/Libretro aiming for simplicity and ease of use. "
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="+lto"


pre_configure_target() {

if [ "${DEVICE}" == "Amlogic-old" ]; then
	PKG_MAKE_OPTS_TARGET=" platform=emuelec"
elif [ "${DEVICE}" == "Amlogic-ng" ] || [ "${DEVICE}" == "Amlogic-no" ] || ["${DEVICE}" == "Amlogic-ogu" ]; then
	PKG_MAKE_OPTS_TARGET=" platform=emuelec-ng"
else
	PKG_MAKE_OPTS_TARGET=" platform=emuelec-hh"
fi	
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp dosbox_pure_libretro.so ${INSTALL}/usr/lib/libretro/dosbox_pure_libretro.so
  cp dosbox_pure_libretro.info ${INSTALL}/usr/lib/libretro/dosbox_pure_libretro.info
  
}
