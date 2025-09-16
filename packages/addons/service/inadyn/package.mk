# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="inadyn"
PKG_VERSION="2.10.0"
PKG_SHA256="a9bc24ea8d59644f909dd98bf3b8efcfb95c153f46d9cb62e99d744d44ed9465"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="http://troglobit.com/inadyn.html"
PKG_URL="https://github.com/troglobit/inadyn/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libconfuse openssl"
PKG_SECTION="service/system"
PKG_SHORTDESC="Inadyn: a small and simple Dynamic Domain Name System client"
PKG_LONGDESC="Inadyn (${PKG_VERSION}) is a small and simple Dynamic Domain Name System (DDNS) client with HTTPS support. It is commonly available in many GNU/Linux distributions, used in off-the-shelf routers and Internet gateways to automate the task of keeping your DNS record up to date with any IP address changes from your ISP. It can also be used in installations with redundant (backup) connections to the Internet."
PKG_TOOLCHAIN="autotools"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Inadyn"
PKG_ADDON_TYPE="xbmc.service"
PKG_MAINTAINER="Anton Voyl (awiouy)"

PKG_CONFIGURE_OPTS_TARGET="--enable-openssl"

makeinstall_target() {
  :
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/inadyn ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}
