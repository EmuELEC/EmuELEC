# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sundtek-mediatv"
PKG_VERSION="7.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="nonfree"
PKG_SITE="http://support.sundtek.com/"
PKG_URL=""
PKG_DEPENDS_TARGET="xmlstarlet:host p7zip:host"
PKG_SECTION="driver/dvb"
PKG_SHORTDESC="Sundtek MediaTV: a Linux driver to add support for SUNDTEK USB DVB devices"
PKG_LONGDESC="Install this to add support for Sundtek USB DVB devices."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Sundtek MediaTV"
PKG_ADDON_TYPE="xbmc.service"

make_target() {
  mkdir -p ${PKG_BUILD}
  cd ${PKG_BUILD}

  case ${TARGET_ARCH} in
    x86_64)
      INSTALLER_URL="http://sundtek.de/media/netinst/64bit/installer.tar.gz"
      ;;
    arm)
      INSTALLER_URL="http://sundtek.de/media/netinst/armsysvhf/installer.tar.gz"
      ;;
    aarch64)
      INSTALLER_URL="http://sundtek.de/media/netinst/arm64/installer.tar.gz"
      ;;
  esac

  wget -O installer.tar.gz ${INSTALLER_URL}

  tar -xzf installer.tar.gz

  chmod -R 755 opt/ etc/

  rm -f  opt/bin/getinput.sh
  rm -f  opt/bin/lirc.sh
  rm -fr opt/lib/pm/

  wget -O version.used http://sundtek.de/media/latest.phtml
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config/
  cp -P ${PKG_DIR}/config/* ${ADDON_BUILD}/${PKG_ADDON_ID}/config/
  cp -P ${PKG_DIR}/settings-default.xml ${ADDON_BUILD}/${PKG_ADDON_ID}/
  cp -Pa ${PKG_BUILD}/opt/bin ${ADDON_BUILD}/${PKG_ADDON_ID}/
  cp -Pa ${PKG_BUILD}/opt/lib ${ADDON_BUILD}/${PKG_ADDON_ID}/
  cp ${PKG_BUILD}/version.used ${ADDON_BUILD}/${PKG_ADDON_ID}/
}
