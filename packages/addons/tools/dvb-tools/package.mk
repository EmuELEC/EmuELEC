# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dvb-tools"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_SHORTDESC="DVB-Tools: is a bundle of dvb tools and programs"
PKG_LONGDESC="This bundle currently includes blindscan-s2, dvb-apps, dvblast, dvbsnoop, mumudvb, szap-s2, tune-s2, t2scan and w_scan."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="DVB Tools"
PKG_ADDON_TYPE="xbmc.python.script"

PKG_DEPENDS_TARGET="toolchain \
                    blindscan-s2 \
                    dvb-apps \
                    dvblast \
                    dvbsnoop \
                    mumudvb \
                    szap-s2 \
                    tune-s2 \
                    t2scan \
                    w_scan"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

    # blindscan-s2
    cp -P $(get_install_dir blindscan-s2)/usr/bin/blindscan-s2 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # dvb-apps
    cp -P $(get_install_dir dvb-apps)/usr/bin/dvbdate ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/dvbnet ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/dvbscan ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/dvbtraffic ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/femon ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/scan ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/azap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/czap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/szap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/tzap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir dvb-apps)/usr/bin/zap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # dvblast
    cp -P $(get_install_dir dvblast)/usr/bin/dvblast ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # dvbsnoop
    cp -P $(get_install_dir dvbsnoop)/usr/bin/dvbsnoop ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # mumudvb
    cp -P $(get_install_dir mumudvb)/usr/bin/mumudvb ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # szap-s2
    cp -P $(get_install_dir szap-s2)/usr/bin/szap-s2 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # tune-s2
    cp -P $(get_install_dir tune-s2)/usr/bin/tune-s2 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # t2scan
    cp -P $(get_install_dir t2scan)/usr/bin/t2scan ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # w_scan
    cp -P $(get_install_dir w_scan)/usr/bin/w_scan ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}
