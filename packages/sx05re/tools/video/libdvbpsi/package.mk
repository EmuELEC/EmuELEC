# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="libdvbpsi"
PKG_VERSION="1.3.0"
PKG_SHA256="a2fed1d11980662f919bbd1f29e2462719e0f6227e1a531310bd5a706db0a1fe"
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org/developers/libdvbpsi.html"
PKG_URL="http://download.videolan.org/pub/libdvbpsi/${PKG_VERSION}/libdvbpsi-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="tools"
PKG_SHORTDESC="library for MPEG TS and DVB PSI tables decoding and generating"
PKG_LONGDESC="libdvbpsi is a simple library designed for MPEG TS and DVB PSI tables decoding and generating."
PKG_IS_ADDON="no"
PKG_AUTORECONF="yes"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
