# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="pcaudiolib"
PKG_VERSION="c651ccb767abede0228570968293219e429899d5"
PKG_SHA256="6cfd54c227fadecadf6e2e175ab4928395fe736846e0f6c0a30f7a20fff988d5"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/espeak-ng/pcaudiolib"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="eSpeak NG is an open source speech synthesizer that supports more than a hundred languages and accents"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+sysroot"

pre_configure() {

PKG_CONFIGURE_OPTS_TARGET="--with-pulseaudio=no"

cd ..
./autogen.sh
}

#post_makeinstall_target(){
#mkdir -p ${SYSROOT_PREFIX}/usr
#cp -rf ${INSTALL}/usr/* ${SYSROOT_PREFIX}/usr/
#}
