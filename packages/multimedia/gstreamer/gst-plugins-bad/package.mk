# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gst-plugins-bad"
PKG_VERSION="1.22.0"
PKG_SHA256="3c9d9300f5f4fb3e3d36009379d1fb6d9ecd79c1a135df742b8a68417dd663a1"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://gstreamer.freedesktop.org/modules/gst-plugins-bad.html"
PKG_URL="https://gstreamer.freedesktop.org/src/gst-plugins-bad/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain gst-plugins-base"
PKG_LONGDESC="GStreamer Bad Plug-ins is a set of plug-ins that aren't up to par compared to the rest."

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Dgst_play_tests=false \
                         -Daccurip=disabled \
                         -Dadpcmdec=disabled \
                         -Dadpcmenc=disabled \
                         -Daiff=disabled \
                         -Dasfmux=disabled \
                         -Daudiobuffersplit=disabled \
                         -Daudiofxbad=disabled \
                         -Daudiolatency=disabled \
                         -Daudiomixmatrix=disabled \
                         -Daudiovisualizers=disabled \
                         -Dautoconvert=disabled \
                         -Dbayer=disabled \
                         -Dcamerabin2=disabled \
                         -Dcoloreffects=disabled \
                         -Ddebugutils=disabled \
                         -Ddvbsubenc=disabled \
                         -Ddvbsuboverlay=disabled \
                         -Ddvdspu=disabled \
                         -Dfaceoverlay=disabled \
                         -Dfestival=disabled \
                         -Dfieldanalysis=disabled \
                         -Dfreeverb=disabled \
                         -Dfrei0r=disabled \
                         -Dgaudieffects=disabled \
                         -Dgdp=disabled \
                         -Dgeometrictransform=disabled \
                         -Did3tag=disabled \
                         -Dinter=disabled \
                         -Dinterlace=disabled \
                         -Divfparse=disabled \
                         -Divtc=disabled \
                         -Djp2kdecimator=disabled \
                         -Djpegformat=disabled \
                         -Dlibrfb=disabled \
                         -Dmidi=disabled \
                         -Dmpegdemux=disabled \
                         -Dmpegpsmux=disabled \
                         -Dmpegtsdemux=disabled \
                         -Dmpegtsmux=disabled \
                         -Dmxf=disabled \
                         -Dnetsim=disabled \
                         -Donvif=disabled \
                         -Dpcapparse=disabled \
                         -Dpnm=disabled \
                         -Dproxy=disabled \
                         -Drawparse=disabled \
                         -Dremovesilence=disabled \
                         -Drist=disabled \
                         -Drtmp2=disabled \
                         -Drtp=disabled \
                         -Dsdp=disabled \
                         -Dsegmentclip=disabled \
                         -Dsiren=disabled \
                         -Dsmooth=disabled \
                         -Dspeed=disabled \
                         -Dsubenc=disabled \
                         -Dswitchbin=disabled \
                         -Dtimecode=disabled \
                         -Dvideofilters=disabled \
                         -Dvideoframe_audiolevel=disabled \
                         -Dvideoparsers=enabled \
                         -Dvideosignal=disabled \
                         -Dvmnc=disabled \
                         -Dy4m=disabled \
                         -Dopencv=disabled \
                         -Dwayland=disabled \
                         -Dx11=disabled \
                         -Daom=disabled \
                         -Davtp=disabled \
                         -Dandroidmedia=disabled \
                         -Dapplemedia=disabled \
                         -Dassrender=disabled \
                         -Dbluez=disabled \
                         -Dbs2b=disabled \
                         -Dbz2=disabled \
                         -Dchromaprint=disabled \
                         -Dclosedcaption=disabled \
                         -Dcolormanagement=disabled \
                         -Dcurl=disabled \
                         -Dcurl-ssh2=disabled \
                         -Dd3dvideosink=disabled \
                         -Dd3d11=disabled \
                         -Ddash=disabled \
                         -Ddc1394=disabled \
                         -Ddecklink=disabled \
                         -Ddirectfb=disabled \
                         -Ddirectsound=disabled \
                         -Ddtls=disabled \
                         -Ddts=disabled \
                         -Ddvb=disabled \
                         -Dfaac=disabled \
                         -Dfaad=disabled \
                         -Dfbdev=disabled \
                         -Dfdkaac=disabled \
                         -Dflite=disabled \
                         -Dfluidsynth=disabled \
                         -Dgl=disabled \
                         -Dgme=disabled \
                         -Dgsm=disabled \
                         -Dipcpipeline=disabled \
                         -Diqa=disabled \
                         -Dkate=disabled \
                         -Dkms=disabled \
                         -Dladspa=disabled \
                         -Dlibde265=disabled \
                         -Dlv2=disabled \
                         -Dmediafoundation=disabled \
                         -Dmicrodns=disabled \
                         -Dmodplug=disabled \
                         -Dmpeg2enc=disabled \
                         -Dmplex=disabled \
                         -Dmsdk=disabled \
                         -Dmusepack=disabled \
                         -Dneon=disabled \
                         -Dnvcodec=disabled \
                         -Dopenal=disabled \
                         -Dopenexr=disabled \
                         -Dopenh264=disabled \
                         -Dopenjpeg=disabled \
                         -Dopenmpt=disabled \
                         -Dopenni2=disabled \
                         -Dopensles=disabled \
                         -Dopus=disabled \
                         -Dresindvd=disabled \
                         -Drsvg=disabled \
                         -Drtmp=disabled \
                         -Dsbc=disabled \
                         -Dsctp=disabled \
                         -Dshm=disabled \
                         -Dsmoothstreaming=disabled \
                         -Dsndfile=disabled \
                         -Dsoundtouch=disabled \
                         -Dspandsp=disabled \
                         -Dsrt=disabled \
                         -Dsrtp=disabled \
                         -Dsvthevcenc=disabled \
                         -Dteletext=disabled \
                         -Dtinyalsa=disabled \
                         -Dtranscode=disabled \
                         -Dttml=disabled \
                         -Duvch264=disabled \
                         -Dva=disabled \
                         -Dvoaacenc=disabled \
                         -Dvoamrwbenc=disabled \
                         -Dvulkan=disabled \
                         -Dwasapi=disabled \
                         -Dwasapi2=disabled \
                         -Dwebp=disabled \
                         -Dwebrtc=disabled \
                         -Dwebrtcdsp=disabled \
                         -Dwildmidi=disabled \
                         -Dwinks=disabled \
                         -Dwinscreencap=disabled \
                         -Dx265=disabled \
                         -Dzbar=disabled \
                         -Dzxing=disabled \
                         -Dwpe=disabled \
                         -Dmagicleap=disabled \
                         -Dv4l2codecs=disabled \
                         -Dhls=disabled \
                         -Dsctp-internal-usrsctp=disabled \
                         -Dexamples=disabled \
                         -Dtests=disabled \
                         -Dintrospection=disabled \
                         -Dnls=disabled \
                         -Dorc=disabled \
                         -Dgobject-cast-checks=disabled \
                         -Dglib-asserts=disabled \
                         -Dglib-checks=disabled \
                         -Dpackage-name=gst-plugins-bad \
                         -Dpackage-origin=LibreELEC.tv \
                         -Ddoc=disabled"
}

post_makeinstall_target() {
  # clean up
  safe_remove ${INSTALL}/usr/bin
  for PKG_GST_PLUGINS_BAD in \
    libgstadaptivedemux libgstbadaudio libgstbasecamerabinsrc libgstcodecs \
    libgstinsertbin libgstisoff libgstmpegts libgstphotography libgstplayer \
    libgstsctp libgsttranscoder libgsturidownloader libgstwebrtc
  do
    safe_remove ${INSTALL}/usr/lib/${PKG_GST_PLUGINS_BAD}-1.0*
  done
  safe_remove ${INSTALL}/usr/share
}
