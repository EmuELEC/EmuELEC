# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="net-snmp"
PKG_VERSION="5.9.4"
PKG_SHA256="8b4de01391e74e3c7014beb43961a2d6d6fa03acc34280b9585f4930745b0544"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="BSD"
PKG_SITE="http://www.net-snmp.org"
PKG_URL="https://sourceforge.net/projects/net-snmp/files/${PKG_NAME}/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libnl openssl"
PKG_SECTION="service"
PKG_SHORTDESC="Simple Network Management Protocol utilities."
PKG_LONGDESC="Simple Network Management Protocol (SNMP) is a widely used protocol for monitoring the health and welfare of network equipment."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Net-SNMP"
PKG_ADDON_TYPE="xbmc.service"

configure_package() {
  PKG_CONFIGURE_OPTS_TARGET="--with-defaults \
        --disable-applications \
        --disable-manuals \
        --disable-debugging \
        --disable-deprecated \
        --disable-snmptrapd-subagent \
        --disable-scripts \
        --enable-static=yes \
        --enable-shared=no \
        --with-nl \
        --with-logfile=/storage/.kodi/userdata/addon_data/${PKG_ADDON_ID} \
        --with-persistent-directory=/storage/.kodi/userdata/addon_data/${PKG_ADDON_ID} \
        --sysconfdir=/storage/.kodi/userdata/addon_data/${PKG_ADDON_ID} \
        --prefix=/storage/.kodi/addons/${PKG_ADDON_ID} \
        --exec-prefix=/storage/.kodi/addons/${PKG_ADDON_ID} \
        --datarootdir=/storage/.kodi/userdata/addon_data/${PKG_ADDON_ID}/share \
        --bindir=/storage/.kodi/addons/${PKG_ADDON_ID}/bin \
        --sbindir=/storage/.kodi/addons/${PKG_ADDON_ID}/bin \
        --libdir=/storage/.kodi/addons/${PKG_ADDON_ID}/lib \
        --disable-embedded-perl \
        --with-sysroot=${SYSROOT_PREFIX}"
}

make_target() {
  make
}

makeinstall_target() {
  make install INSTALL_PREFIX=${INSTALL}
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/lib
  cp -r ${PKG_INSTALL}/storage/.kodi/addons/${PKG_ADDON_ID}/bin ${PKG_INSTALL}/storage/.kodi/userdata/addon_data/${PKG_ADDON_ID}/share ${ADDON_BUILD}/${PKG_ADDON_ID}/
}
