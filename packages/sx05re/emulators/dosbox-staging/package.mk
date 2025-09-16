# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="dosbox-staging"
PKG_VERSION="3f67c91dd6a998cc091f24d2200e2b99cf37fb18"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/dosbox-staging/dosbox-staging"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain linux meson:host glibc glib systemd dbus alsa-lib SDL2 SDL2_net SDL_sound libpng zlib libvorbis flac libogg fluidsynth-git munt opusfile"
PKG_LONGDESC="DOS/x86 emulator focusing on ease of use "
PKG_BUILD_FLAGS="+lto"

## For some reason my build PC needs this to download fluidsynth 
# sudo apt install ca-certificates
# sudo update-ca-certificates --fresh

## And this to locate them
export SSL_CERT_DIR=/etc/ssl/certs

pre_configure_target() {
PKG_MESON_OPTS_TARGET=" -Duse_opengl=false"
sed -i "s|C_MANYMOUSE') == true)|C_MANYMOUSE') == false)|" ${PKG_BUILD}/meson.build
sed -i "s|C_MANYMOUSE', true)|C_MANYMOUSE', false)|" ${PKG_BUILD}/meson.build
}

post_makeinstall_target () {
	mkdir -p ${INSTALL}/usr/config/dosbox
	cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
	cp -a ${PKG_DIR}/config/*  ${INSTALL}/usr/config/dosbox/
	cp -a ${PKG_BUILD}/contrib/resources/*  ${INSTALL}/usr/config/dosbox/
	rm -rf ${INSTALL}/usr/share
	find ${INSTALL}/usr/config/dosbox -name "meson.build" -exec rm -rf {} \;
}
