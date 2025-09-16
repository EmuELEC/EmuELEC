# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mpv-drmprime"
PKG_VERSION="0.36.0"
PKG_SHA256="29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
PKG_LICENSE="GPL"
PKG_SITE="https://mpv.io/"
PKG_URL="https://github.com/mpv-player/mpv/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain waf:host alsa ffmpeg libass libdrm lua52"
PKG_LONGDESC="A media player based on MPlayer and mplayer2. It supports a wide variety of video file formats, audio and video codecs, and subtitle types."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

PKG_MANUAL_OPTS_TARGET="--prefix=/usr \
                        --disable-libarchive \
                        --enable-lua \
                        --disable-javascript \
                        --disable-uchardet \
                        --disable-rubberband \
                        --disable-lcms2 \
                        --disable-vapoursynth \
                        --disable-jack \
                        --disable-wayland \
                        --disable-x11 \
                        --disable-vulkan \
                        --disable-caca \
                        --enable-drm \
                        --enable-gbm \
                        --enable-egl-drm"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${VAAPI_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libva"
  PKG_MANUAL_OPTS_TARGET+=" --enable-vaapi --enable-vaapi-drm"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-vaapi"
fi

if [ "${PULSEAUDIO_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" pulseaudio"
  PKG_MANUAL_OPTS_TARGET+=" --enable-pulse"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-pulse"
fi

if [ "${KODI_BLURAY_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libbluray"
  PKG_MANUAL_OPTS_TARGET+=" --enable-libbluray"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-libbluray"
fi

pre_configure_target() {
#mpv does not build in the .TARGET_NAME
  cd ${PKG_BUILD}
    rm -rf .${TARGET_NAME}
}

configure_target() {
  waf configure ${PKG_MANUAL_OPTS_TARGET}
}

make_target() {
  waf build
}

makeinstall_target() {
  waf install --destdir=${INSTALL}
  rm -r ${INSTALL}/usr/share
}
