# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mpv"
PKG_VERSION="bb5b4b1ba61b67da40c85c34376aced9383fc366"
PKG_SHA256="452b0368120be80f9d19c766812e0903245c755d59225efa1dfb4d43da779588"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/mpv-player/mpv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2 youtube-dl libass"
PKG_LONGDESC="Video player based on MPlayer/mplayer2 https://mpv.io"
PKG_TOOLCHAIN="manual"


pre_configure_target() {
	WAFRELEASE="waf-2.0.20"
	WAFURL="https://waf.io/${WAFRELEASE}"
	
if [ ! -e ${SOURCES}/${PKG_NAME}/waf ]; then
	wget "${WAFURL}" -O "${SOURCES}/${PKG_NAME}/waf" || echo "Could not download waf $?"
	chmod +x "${SOURCES}/${PKG_NAME}/waf"
fi

cp ${SOURCES}/${PKG_NAME}/waf ${PKG_BUILD}
}

configure_target() {
  #./bootstrap.py 
  # the bootstrap was failing for some reason. 
	cd ${PKG_BUILD}
 
 if [[ "${DEVICE}" == "OdroidGoAdvance" || "${DEVICE}" == "GameForce" ]]; then
  ./waf configure --enable-sdl2 --enable-sdl2-gamepad --disable-pulse --enable-egl --disable-libbluray --enable-drm --disable-gl
  else
  ./waf configure --enable-libmpv-shared --enable-sdl2 --enable-sdl2-gamepad --disable-pulse --enable-egl --disable-libbluray --disable-drm --disable-gl
 fi
}

make_target() {
  ./waf build
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ./build/mpv ${INSTALL}/usr/bin
}
