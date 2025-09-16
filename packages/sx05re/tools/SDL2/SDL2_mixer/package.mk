# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="SDL2_mixer"
PKG_VERSION="d79638a1b6ff6563a82b57732ce05ca27cc54338"
PKG_GIT_CLONE_BRANCH="SDL2"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libsdl-org/SDL_mixer"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2 mpg123-compat libvorbis libvorbisidec libogg opusfile libmodplug flac"
PKG_LONGDESC="An audio mixer that supports various file formats for Simple Directmedia Layer. "
PKG_DEPENDS_HOST="toolchain:host SDL2:host"

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST="-DSDL2MIXER_OPUS=OFF \
                       -DSDL2MIXER_MOD=OFF \
                       -DSDL2MIXER_MP3=OFF \
                       -DSDL2MIXER_FLAC=OFF \
                       -DSDL2MIXER_MIDI=OFF \
                       -DSDL2MIXER_VORBIS=OFF \
                       -DSDL2MIXER_OGG=OFF \
                       -DSDL2MIXER_MOD_XMP=OFF \
                       -DSDL2MIXER_WAVPACK=OFF"
}

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="-DSDL2MIXER_MIDI_FLUIDSYNTH=OFF \
                       -DSDL2MIXER_FLAC=ON \
                       -DSDL2MIXER_MOD_MODPLUG=ON \
                       -DSDL2MIXER_VORBIS_TREMOR=ON \
                       -DSDL2MIXER_OGG=ON \
                       -DSDL2MIXER_MP3=ON \
                       -DSDL2MIXER_SAMPLES=OFF \
                       -DSDL2MIXER_MOD_MODPLUG_SHARED=OFF \
                       -DSDL2MIXER_MOD_XMP=OFF \
                       -DSDL2MIXER_WAVPACK=OFF"
}
