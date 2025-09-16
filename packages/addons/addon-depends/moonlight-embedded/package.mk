# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="moonlight-embedded"
PKG_VERSION="395f474cb87f1b05251e2fce098b502952af3ba9"
PKG_SHA256="8d749d07144fe22febe292abc8a06b93509cfac389fbeb219f18f7925a354c1e"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/TheChoconut/moonlight-embedded"
PKG_URL="https://github.com/TheChoconut/moonlight-embedded/archive/${PKG_VERSION}.tar.gz"
PKG_MAINTAINER="TheChoconut"
PKG_DEPENDS_TARGET="toolchain curl pulseaudio systemd alsa-lib moonlight-common-c libevdev sdlgamecontrollerdb enet opus libamcodec"
PKG_SECTION=""
PKG_SHORTDESC="Open source NVIDIA GameStream Linux client"
PKG_LONGDESC="Moonlight Embedded is an open source implementation of NVIDIA's GameStream, as used by the NVIDIA Shield, but built for Linux."
PKG_CMAKE_OPTS_TARGET="-DENABLE_FFMPEG=OFF -DENABLE_CEC=OFF -DENABLE_SDL=OFF"

pre_build_target() {
  cp -a $(get_build_dir moonlight-common-c)/* ${PKG_BUILD}/third_party/moonlight-common-c
  cp -a $(get_build_dir sdlgamecontrollerdb)/* ${PKG_BUILD}/third_party/SDL_GameControllerDB
  cp -a $(get_build_dir enet)/* ${PKG_BUILD}/third_party/moonlight-common-c/enet
}
