# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="fluidsynth-git"
PKG_VERSION="2.0.6"
PKG_SHA256="e97e63c1045e102465f1aa848f9d712c5528c58685b8d40062e4aaf6af7edb75"
PKG_LICENSE="LGPL"
PKG_SITE="http://fluidsynth.org/"
PKG_URL="https://github.com/FluidSynth/fluidsynth/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib soundfont-generaluser"
PKG_LONGDESC="FluidSynth is a software real-time synthesizer based on the Soundfont 2 specifications."
PKG_BUILD_FLAGS="+pic"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DLIB_SUFFIX= \
                         -Denable-readline=0 \
                         -Denable-oss=0 \
                         -Denable-pulseaudio=1 \
                         -Denable-libsndfile=0"
}

post_makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/etc/fluidsynth
  mkdir -p ${INSTALL}/usr/config/fluidsynth/soundfonts

  # Create symlinks & install config file
  cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/fluidsynth/
  ln -s /storage/.config/fluidsynth/fluidsynth.conf ${INSTALL}/etc/fluidsynth/
  echo "Place your SoundFonts here!" >> ${INSTALL}/usr/config/fluidsynth/soundfonts/readme.txt

  # Create symlink to SoundFont
  ln -s /usr/share/soundfonts/GeneralUser.sf2  ${INSTALL}/usr/config/fluidsynth/soundfonts/
}
