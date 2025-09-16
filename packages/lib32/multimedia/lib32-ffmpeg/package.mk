# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-ffmpeg"
PKG_VERSION="$(get_pkg_version ffmpeg)"
PKG_NEED_UNPACK="$(get_pkg_directory ffmpeg)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPLv2.1+"
PKG_SITE="https://ffmpeg.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib lib32-bzip2 lib32-openssl lib32-SDL2"
PKG_LONGDESC="FFmpeg is a complete, cross-platform solution to record, convert and stream audio and video."
PKG_BUILD_FLAGS="lib32 -gold"

FF_DIRECTORY="$(get_pkg_directory ffmpeg)"
PKG_PATCH_DIRS+=" ${FF_DIRECTORY}/patches \
                  ${FF_DIRECTORY}/patches/libreelec \
                  ${FF_DIRECTORY}/patches/v4l2-request \
                  ${FF_DIRECTORY}/patches/v4l2-drmprime" 

# Dependencies
get_graphicdrivers

if [ "${V4L2_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" lib32-libdrm"
  PKG_NEED_UNPACK+=" $(get_pkg_directory lib32-libdrm)"
  PKG_FFMPEG_V4L2="--enable-v4l2_m2m --enable-libdrm"

  if [ "${PROJECT}" = "Rockchip" ]; then
    PKG_V4L2_REQUEST="yes"
    PKG_DEPENDS_TARGET+=" lib32-systemd-libs"
    PKG_NEED_UNPACK+=" $(get_pkg_directory lib32-systemd-libs)"
    PKG_FFMPEG_V4L2+=" --enable-libudev --enable-v4l2-request"
  else
    PKG_V4L2_REQUEST="no"
    PKG_FFMPEG_V4L2+=" --disable-libudev --disable-v4l2-request"
  fi
else
  PKG_FFMPEG_V4L2="--disable-v4l2_m2m --disable-libudev --disable-v4l2-request"
fi

if [ "${DISPLAYSERVER}" != "x11" ] && [ "${PROJECT}" != "Amlogic-ce" ]; then
  PKG_DEPENDS_TARGET+=" lib32-libdrm"
  PKG_NEED_UNPACK+=" $(get_pkg_directory lib32-libdrm)"
  PKG_FFMPEG_LIBDRM=" --enable-libdrm"
fi

unpack() {
  ${SCRIPTS}/get ffmpeg
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/ffmpeg/ffmpeg-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_target() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}
  if [ ${DISTRO} == "EmuELEC" ]; then
    sed -i "s|int hide_banner = 0|int hide_banner = 1|" ${PKG_BUILD}/fftools/cmdutils.c
    sed -i "s|SDL2_CONFIG=\"\${cross_prefix}sdl2-config\"|SDL2_CONFIG=\"${SYSROOT_PREFIX}/usr/bin/sdl2-config\"|" ${PKG_BUILD}/configure
  fi
}

configure_target() {
  ./configure --prefix="/usr" \
              --cpu="${LIB32_TARGET_CPU}" \
              --arch=arm \
              --enable-cross-compile \
              --cross-prefix="${TARGET_PREFIX}" \
              --sysroot="${SYSROOT_PREFIX}" \
              --sysinclude="${SYSROOT_PREFIX}/usr/include" \
              --target-os="linux" \
              --nm="${NM}" \
              --ar="${AR}" \
              --as="${CC}" \
              --cc="${CC}" \
              --ld="${CC}" \
              --host-cc="${HOST_CC}" \
              --host-cflags="${HOST_CFLAGS}" \
              --host-ldflags="${HOST_LDFLAGS}" \
              --extra-cflags="${CFLAGS}" \
              --extra-ldflags="${LDFLAGS}" \
              --extra-libs="${PKG_FFMPEG_LIBS}" \
              --disable-static \
              --enable-shared \
              --enable-gpl \
              --enable-version3 \
              --enable-logging \
              --disable-doc \
              --disable-debug \
              --enable-stripping \
              --enable-pic \
              --pkg-config="${TOOLCHAIN}/bin/pkg-config" \
              --enable-optimizations \
              --disable-extra-warnings \
              --enable-avdevice \
              --enable-avcodec \
              --enable-avformat \
              --enable-swscale \
              --enable-postproc \
              --enable-avfilter \
              --enable-pthreads \
              --enable-network \
              --disable-gnutls \
              --enable-openssl \
              --disable-gray \
              --enable-swscale-alpha \
              --disable-small \
              --enable-dct \
              --enable-fft \
              --enable-mdct \
              --enable-rdft \
              --disable-crystalhd \
              ${PKG_FFMPEG_V4L2} \
              --disable-vaapi \
              --disable-vdpau \
              ${PKG_FFMPEG_LIBDRM} \
              --enable-runtime-cpudetect \
              --disable-hardcoded-tables \
              --enable-encoder=ac3 \
              --enable-encoder=aac \
              --enable-encoder=wmav2 \
              --enable-encoder=mjpeg \
              --enable-encoder=png \
              --enable-encoder=mpeg4 \
              --enable-hwaccels \
              --enable-muxer=spdif \
              --enable-muxer=adts \
              --enable-muxer=asf \
              --enable-muxer=ipod \
              --enable-muxer=mpegts \
              --enable-demuxers \
              --enable-parsers \
              --enable-bsfs \
              --enable-protocol=http \
              --enable-filters \
              --disable-avisynth \
              --enable-bzlib \
              --disable-lzma \
              --disable-alsa \
              --disable-frei0r \
              --disable-libopencore-amrnb \
              --disable-libopencore-amrwb \
              --disable-libopencv \
              --disable-libdc1394 \
              --disable-libfreetype \
              --disable-libgsm \
              --disable-libmp3lame \
              --disable-libopenjpeg \
              --disable-librtmp \
              --disable-libdav1d \
              --disable-libspeex \
              --disable-libtheora \
              --disable-libvo-amrwbenc \
              --disable-libvorbis \
              --disable-libvpx \
              --disable-libx264 \
              --disable-libxavs \
              --disable-libxvid \
              --enable-zlib \
              --enable-asm \
              --disable-altivec \
              --enable-neon \
              --disable-symver
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
