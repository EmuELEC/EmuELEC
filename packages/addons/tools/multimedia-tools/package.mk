# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="multimedia-tools"
PKG_VERSION="1.0"
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_SHORTDESC="A bundle of multimedia tools and programs"
PKG_LONGDESC="This bundle currently includes alsamixer, mediainfo, mpg123, opencaster, squeezelite, tsdecrypt and tstools."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Multimedia Tools"
PKG_ADDON_TYPE="xbmc.python.script"

PKG_DEPENDS_TARGET="toolchain \
                    alsa-utils \
                    mediainfo \
                    mpg123 \
                    opencaster \
                    squeezelite \
                    tsdecrypt \
                    tstools"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/
    # alsamixer
    cp -P $(get_install_dir alsa-utils)/.noinstall/alsamixer ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

    # mediainfo
    cp -P $(get_install_dir mediainfo)/usr/bin/mediainfo ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # mpg123
    cp -P $(get_install_dir mpg123)/usr/bin/* ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

    # opencaster
    cp -P $(get_install_dir opencaster)/usr/bin/* ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

    # squeezelite
    cp -P $(get_install_dir squeezelite)/usr/bin/squeezelite ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

    # tsdecrypt
    cp -P $(get_install_dir tsdecrypt)/usr/bin/tsdecrypt ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # tstools
    cp -P $(get_install_dir tstools)/usr/bin/* ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/
}
