# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present CoreELEC (https://coreelec.org)

PKG_NAME="Skyscraper"
PKG_VERSION="03d8d657d1ea3dfc5d3b1047922b76971bdf5ff5"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/muldjord/skyscraper"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain qt-everywhere p7zip:host"
PKG_PRIORITY="optional"
PKG_SECTION="emuelec"
PKG_SHORTDESC="Powerful and versatile game scraper written in c++ "
PKG_TOOLCHAIN="make"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make" 

configure_target() {
  # Fix install paths / 5schatten
  sed -e "s#target.path=/usr/local/bin#target.path=${INSTALL}/usr/bin#"                                                       -i ${PKG_BUILD}/skyscraper.pro
  sed -e "s#examples.path=/usr/local/etc/skyscraper#examples.path=${INSTALL}/usr/share/skyscraper#"                           -i ${PKG_BUILD}/skyscraper.pro
  sed -e "s#cacheexamples.path=/usr/local/etc/skyscraper/cache#cacheexamples.path=${INSTALL}/usr/share/skyscraper/cache#"     -i ${PKG_BUILD}/skyscraper.pro
  sed -e "s#impexamples.path=/usr/local/etc/skyscraper/import#impexamples.path=${INSTALL}/usr/share/skyscraper/import#"       -i ${PKG_BUILD}/skyscraper.pro
  sed -e "s#resexamples.path=/usr/local/etc/skyscraper/resources#resexamples.path=${INSTALL}/usr/share/skyscraper/resources#" -i ${PKG_BUILD}/skyscraper.pro

  rm -rf .qmake.stash
  QMAKEPATH="$(get_build_dir qt-everywhere)/qtbase/bin/qmake"
  ${QMAKEPATH} ${PKG_BUILD}/skyscraper.pro
}

post_makeinstall_target() {
  # Install scripts 
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/

  # Install config
  mkdir -p ${INSTALL}/usr/config/skyscraper
  cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/skyscraper/
}

