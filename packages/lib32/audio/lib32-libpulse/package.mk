# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libpulse"
PKG_VERSION="$(get_pkg_version pulseaudio)"
PKG_NEED_UNPACK="$(get_pkg_directory pulseaudio)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://pulseaudio.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib lib32-dbus lib32-libcap lib32-libsndfile lib32-openssl lib32-systemd-libs glib:host lib32-glib"
PKG_PATCH_DIRS+=" $(get_pkg_directory pulseaudio)/patches"
PKG_LONGDESC="PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for your sound applications."
PKG_BUILD_FLAGS="lib32"

PKG_MESON_OPTS_TARGET="-Ddaemon=false \
                       -Ddoxygen=false \
                       -Dgcov=false \
                       -Dman=false \
                       -Dtests=false \
                       -Dsystem_user=root \
                       -Dsystem_group=root \
                       -Daccess_group=root \
                       -Ddatabase=simple \
                       -Dlegacy-database-entry-format=false \
                       -Dstream-restore-clear-old-devices=false \
                       -Drunning-from-build-tree=false \
                       -Datomic-arm-linux-helpers=true \
                       -Datomic-arm-memory-barrier=false \
                       -Dmodlibexecdir=/usr/lib/pulse \
                       -Dudevrulesdir=/usr/lib/udev/rules.d \
                       -Dbashcompletiondir=no \
                       -Dzshcompletiondir=no \
                       -Dalsa=enabled \
                       -Dasyncns=disabled \
                       -Davahi=disabled \
                       -Dbluez5=disabled
                       -Dbluez5-gstreamer=disabled \
                       -Dbluez5-native-headset=false \
                       -Dbluez5-ofono-headset=false \
                       -Ddbus=enabled \
                       -Delogind=disabled \
                       -Dfftw=disabled \
                       -Dglib=enabled \
                       -Dgsettings=disabled \
                       -Dgstreamer=disabled \
                       -Dgtk=disabled \
                       -Dhal-compat=false \
                       -Dipv6=true \
                       -Djack=disabled \
                       -Dlirc=disabled \
                       -Dopenssl=enabled \
                       -Dorc=disabled \
                       -Doss-output=disabled \
                       -Dsamplerate=disabled \
                       -Dsoxr=disabled \
                       -Dspeex=disabled \
                       -Dsystemd=enabled \
                       -Dtcpwrap=disabled \
                       -Dudev=enabled \
                       -Dvalgrind=disabled \
                       -Dx11=disabled \
                       -Dadrian-aec=true \
                       -Dwebrtc-aec=disabled"


unpack() {
  ${SCRIPTS}/get pulseaudio
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/pulseaudio/pulseaudio-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

pre_configure_target() {
  sed -e 's|; remixing-use-all-sink-channels = yes|; remixing-use-all-sink-channels = no|' \
      -i ${PKG_BUILD}/src/daemon/daemon.conf.in
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/etc
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
  mkdir -p ${INSTALL}/etc/ld.so.conf.d
    echo /usr/lib32/pulseaudio > ${INSTALL}/etc/ld.so.conf.d/pulseaudio.conf
    echo /usr/lib/pulseaudio >> ${INSTALL}/etc/ld.so.conf.d/pulseaudio.conf
}
