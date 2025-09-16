# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="chrome"
PKG_VERSION="1.0"
# curl -s http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages | grep -B 1 Version
PKG_VERSION_NUMBER="109.0.5414.74"
PKG_REV="0"
PKG_ARCH="x86_64"
PKG_LICENSE="Custom"
PKG_SITE="http://www.google.com/chrome"
PKG_DEPENDS_TARGET="toolchain at-spi2-atk atk cairo chrome-libXcomposite \
                    chrome-libXdamage chrome-libXfixes chrome-libXi chrome-libXrender \
                    chrome-libXtst chrome-libxcb chrome-libxkbcommon chrome-libxshmfence cups \
                    gdk-pixbuf gtk3 harfbuzz-icu libXcursor libxss nss pango \
                    scrnsaverproto unclutter unix_ar"
PKG_SECTION="browser"
PKG_SHORTDESC="Google Chrome Browser"
PKG_LONGDESC="Google Chrome Browser"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Chrome"
PKG_ADDON_TYPE="xbmc.python.script"
PKG_ADDON_PROVIDES="executable"

make_target() {
  :
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,config,lib,resources}

  # config
  cp -P ${PKG_DIR}/config/* ${ADDON_BUILD}/${PKG_ADDON_ID}/config

  # unclutter
  cp -P $(get_install_dir unclutter)/usr/bin/unclutter ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

  # libs
  cp -PL $(get_install_dir atk)/usr/lib/libatk-1.0.so.0 \
         $(get_install_dir cairo)/usr/lib/{libcairo-gobject.so.2,libcairo.so.2} \
         $(get_install_dir gdk-pixbuf)/usr/lib/libgdk_pixbuf-2.0.so.0 \
         $(get_install_dir gtk3)/usr/lib/{libgtk-3.so.0,libgdk-3.so.0} \
         $(get_install_dir harfbuzz-icu)/usr/lib/{libharfbuzz.so.0,libharfbuzz-icu.so*} \
         $(get_install_dir at-spi2-atk)/usr/lib/libatk-bridge-2.0.so.0 \
         $(get_install_dir at-spi2-core)/usr/lib/libatspi.so.0 \
         $(get_install_dir cups)/usr/lib/libcups.so.2 \
         $(get_install_dir chrome-libxcb)/usr/lib/{libxcb.so.1,libxcb-dri3.so.0} \
         $(get_install_dir chrome-libXcomposite)/usr/lib/libXcomposite.so.1 \
         $(get_install_dir libXcursor)/usr/lib/libXcursor.so.1 \
         $(get_install_dir chrome-libXdamage)/usr/lib/libXdamage.so.1 \
         $(get_install_dir chrome-libXfixes)/usr/lib/libXfixes.so.3 \
         $(get_install_dir chrome-libXi)/usr/lib/libXi.so.6 \
         $(get_install_dir chrome-libxkbcommon)/usr/lib/libxkbcommon.so.0 \
         $(get_install_dir chrome-libXrender)/usr/lib/libXrender.so.1 \
         $(get_install_dir chrome-libxshmfence)/usr/lib/libxshmfence.so.1 \
         $(get_install_dir libxss)/usr/lib/libXss.so.1 \
         $(get_install_dir chrome-libXtst)/usr/lib/libXtst.so.6 \
         $(get_install_dir pango)/usr/lib/{libpangocairo-1.0.so.0,libpango-1.0.so.0,libpangoft2-1.0.so.0} \
         ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

  # unix_ar
  cp -P $(get_build_dir unix_ar)/unix_ar.py ${ADDON_BUILD}/${PKG_ADDON_ID}/resources
}

post_install_addon() {
  sed -e "s/@DISTRO_PKG_SETTINGS_ID@/${DISTRO_PKG_SETTINGS_ID}/g" -i "${INSTALL}/default.py"
  sed -e "s/@CHROME_VERSION@/${PKG_VERSION_NUMBER}/g" -i "${INSTALL}/bin/chrome-downloader"
  sed -e "s/@CHROME_VERSION@/${PKG_VERSION_NUMBER}/g" -i "${INSTALL}/resources/settings.xml"
  sed -e "s/@CHROME_VERSION@/${PKG_VERSION_NUMBER}/g" -i "${INSTALL}/settings-default.xml"
}
