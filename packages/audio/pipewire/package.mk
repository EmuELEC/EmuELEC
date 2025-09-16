# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pipewire"
PKG_VERSION="0.3.66"
PKG_SHA256="36b6028434c16aacfc6695073b7ca4996c5476eb92833340566d27538b635508"
PKG_LICENSE="LGPL"
PKG_SITE="https://pipewire.org"
PKG_URL="https://github.com/PipeWire/pipewire/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpthread-stubs dbus ncurses alsa-lib systemd libsndfile libusb"
PKG_LONGDESC="PipeWire is a server and user space API to deal with multimedia pipeline"

if [ "${BLUETOOTH_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" bluez sbc ldacBT libfreeaptx"
  PKG_PIPEWIRE_BLUETOOTH="-Dbluez5=enabled \
                          -Dbluez5-backend-hsp-native=disabled \
                          -Dbluez5-backend-hfp-native=disabled \
                          -Dbluez5-backend-ofono=disabled \
                          -Dbluez5-backend-hsphfpd=disabled \
                          -Dbluez5-codec-aptx=enabled \
                          -Dbluez5-codec-ldac=enabled \
                          -Dbluez5-codec-aac=disabled"
else
  PKG_PIPEWIRE_BLUETOOTH="-Dbluez5=disabled"
fi

PKG_MESON_OPTS_TARGET="-Ddocs=disabled \
                       -Dexamples=disabled \
                       -Dman=disabled \
                       -Dtests=disabled \
                       -Dinstalled_tests=disabled \
                       -Dgstreamer=disabled \
                       -Dgstreamer-device-provider=disabled \
                       -Dsystemd=enabled \
                       -Dsystemd-system-service=enabled \
                       -Dsystemd-user-service=disabled \
                       -Dpipewire-alsa=enabled \
                       -Dpipewire-jack=disabled \
                       -Dpipewire-v4l2=disabled \
                       -Djack-devel=false
                       -Dspa-plugins=enabled \
                       -Dalsa=enabled \
                       -Daudiomixer=enabled \
                       -Daudioconvert=enabled \
                       ${PKG_PIPEWIRE_BLUETOOTH} \
                       -Dcontrol=enabled \
                       -Daudiotestsrc=disabled \
                       -Dffmpeg=disabled \
                       -Djack=disabled \
                       -Dsupport=enabled \
                       -Devl=disabled \
                       -Dtest=disabled \
                       -Dv4l2=disabled \
                       -Ddbus=enabled \
                       -Dlibcamera=disabled \
                       -Dvideoconvert=disabled \
                       -Dvideotestsrc=disabled \
                       -Dvolume=enabled \
                       -Dvulkan=disabled \
                       -Dpw-cat=enabled \
                       -Dudev=enabled \
                       -Dudevrulesdir=/usr/lib/udev/rules.d \
                       -Dsdl2=disabled \
                       -Dsndfile=enabled \
                       -Dlibpulse=disabled \
                       -Droc=disabled \
                       -Davahi=disabled \
                       -Decho-cancel-webrtc=disabled \
                       -Dlibusb=enabled \
                       -Dsession-managers=[] \
                       -Draop=disabled \
                       -Dlv2=disabled \
                       -Dx11=disabled \
                       -Dx11-xfixes=disabled \
                       -Dlibcanberra=disabled \
                       -Dlegacy-rtkit=false"

post_makeinstall_target() {
  # connect to the system bus
  sed '/^\[Service\]/a Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket' -i ${INSTALL}/usr/lib/systemd/system/pipewire.service
}

post_install() {
  add_user pipewire x 982 980 "pipewire-daemon" "/var/run/pipewire" "/bin/sh"
  add_group pipewire 980
  # note that the pipewire user is added to the audio and video groups in systemd/package.mk
  # todo: maybe there is a better way to add users to groups in the future?

  enable_service pipewire.socket
  enable_service pipewire.service
}
