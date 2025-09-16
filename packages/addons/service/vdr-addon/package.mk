# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2011 Anthony Nash (nash.ant@gmail.com)
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vdr-addon"
PKG_VERSION="2.6.3"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain vdr vdr-plugin-ddci2 vdr-plugin-dummydevice vdr-plugin-dvbapi vdr-plugin-eepg vdr-plugin-epgfixer \
                    vdr-plugin-epgsearch vdr-plugin-iptv vdr-plugin-live vdr-plugin-restfulapi vdr-plugin-robotv vdr-plugin-satip \
                    vdr-plugin-streamdev vdr-plugin-vnsiserver vdr-plugin-wirbelscan vdr-plugin-wirbelscancontrol vdr-plugin-xmltv2vdr"
PKG_SECTION="service.multimedia"
PKG_SHORTDESC="VDR: a TV streaming server for Linux"
PKG_LONGDESC="VDR (2.6.x) is a TV streaming server for Linux supporting DVB-S/S2, DVB-C, DVB-T/T2, IPTV and SAT>IP"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="VDR PVR Backend"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_REQUIRES="pvr.vdr.vnsi:0.0.0 script.config.vdr:0.0.0"

addon() {
  # create dirs
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,lib,plugin,locale}
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config/epgsources
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config/plugins/{eepg,epgfixer,epgsearch,streamdev-server,vnsiserver}
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/res/plugins/{live,restfulapi}

  # configs
  cp -P $(get_build_dir vdr)/{diseqc.conf,keymacros.conf,scr.conf,sources.conf,svdrphosts.conf} ${ADDON_BUILD}/${PKG_ADDON_ID}/config
  cp -P $(get_build_dir vdr-plugin-epgfixer)/epgfixer/*.conf ${ADDON_BUILD}/${PKG_ADDON_ID}/config/plugins/epgfixer
  cp -P $(get_build_dir vdr-plugin-streamdev)/streamdev-server/streamdevhosts.conf ${ADDON_BUILD}/${PKG_ADDON_ID}/config/plugins/streamdev-server
  cp -P $(get_build_dir vdr-plugin-vnsiserver)/vnsiserver/allowed_hosts.conf ${ADDON_BUILD}/${PKG_ADDON_ID}/config/plugins/vnsiserver

  touch ${ADDON_BUILD}/${PKG_ADDON_ID}/config/channels.conf
  echo '0.0.0.0/0' >> ${ADDON_BUILD}/${PKG_ADDON_ID}/config/svdrphosts.conf

  # copy static files
  cp -PR $(get_build_dir vdr-plugin-restfulapi)/web/* \
         $(get_build_dir vdr-plugin-restfulapi)/API.html \
         ${ADDON_BUILD}/${PKG_ADDON_ID}/res/plugins/restfulapi

  cp -PR $(get_build_dir vdr-plugin-live)/live/* ${ADDON_BUILD}/${PKG_ADDON_ID}/res/plugins/live

  cp -P $(get_build_dir vdr-plugin-xmltv2vdr)/dist/epgdata2xmltv/epgdata2xmltv.dist ${ADDON_BUILD}/${PKG_ADDON_ID}/config/epgsources/epgdata2xmltv

  # copy binaries
  for pkg in ddci2 dummydevice dvbapi eepg epgfixer epgsearch iptv live restfulapi robotv satip vnsiserver wirbelscan wirbelscancontrol xmltv2vdr; do
    cp -PR $(get_build_dir vdr-plugin-${pkg})/libvdr*.so.* ${ADDON_BUILD}/${PKG_ADDON_ID}/plugin
  done

  # copy locale (omit ddci, dummydevice, robotv)
  for pkg in dvbapi eepg epgfixer epgsearch iptv live restfulapi satip vnsiserver wirbelscan wirbelscancontrol xmltv2vdr; do
    cp -PR $(get_build_dir vdr-plugin-${pkg})/locale/* ${ADDON_BUILD}/${PKG_ADDON_ID}/locale
  done

  cp -P $(get_build_dir vdr-plugin-streamdev)/client/libvdr*.so.* \
        $(get_build_dir vdr-plugin-streamdev)/server/libvdr*.so.* \
        ${ADDON_BUILD}/${PKG_ADDON_ID}/plugin
  cp -PR $(get_build_dir vdr-plugin-streamdev)/client/locale/* \
        $(get_build_dir vdr-plugin-streamdev)/server/locale/* \
        ${ADDON_BUILD}/${PKG_ADDON_ID}/locale

  cp -PL $(get_install_dir tntnet)/usr/lib/libtntnet.so.13 ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

  cp -P $(get_build_dir vdr)/vdr ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/vdr.bin
  cp -PR $(get_build_dir vdr)/locale/* ${ADDON_BUILD}/${PKG_ADDON_ID}/locale

  cp -P $(get_build_dir vdr-plugin-xmltv2vdr)/dist/epgdata2xmltv/epgdata2xmltv ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}
