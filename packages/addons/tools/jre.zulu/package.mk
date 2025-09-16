# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Peter Vicman (peter.vicman@gmail.com)

PKG_NAME="jre.zulu"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_LICENSE="GPL2"
PKG_DEPENDS_TARGET="jre-libbluray libXext libXi libXrender chrome-libXtst jre-libXinerama"
PKG_DEPENDS_UNPACK="jdk-${TARGET_ARCH}-zulu"
PKG_SECTION="tools"
PKG_SHORTDESC="Java Runtime Environment 8 for Blu-ray Disc Java menus from Azul Systems."
PKG_LONGDESC="${PKG_SHORTDESC}"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="JRE for BD-J menus"
PKG_ADDON_TYPE="xbmc.python.script"

# find ${1}.so.[0-9]* in ${2} and copy it to dest
_pkg_copy_lib() {
  find "${2}/usr/lib" -regextype sed -regex ".*/${1}\.so\.[0-9]*" \
    -exec cp {} "${ADDON_BUILD}/${PKG_ADDON_ID}/lib" \;
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

  cp -a $(get_build_dir jdk-${TARGET_ARCH}-zulu)/jre \
        $(get_install_dir jre-libbluray)/usr/share/java/*.jar \
        ${PKG_DIR}/profile.d \
    ${ADDON_BUILD}/${PKG_ADDON_ID}

  # copy required libraries for JRE
  _pkg_copy_lib libXtst $(get_install_dir chrome-libXtst)
  _pkg_copy_lib libXinerama $(get_install_dir jre-libXinerama)

  if [ "${DISPLAYSERVER}" != "X11" ]; then
    _pkg_copy_lib libXi $(get_install_dir libXi)
    _pkg_copy_lib libXrender $(get_install_dir libXrender)
    _pkg_copy_lib libX11 $(get_install_dir libX11)
    _pkg_copy_lib libXext $(get_install_dir libXext)
    _pkg_copy_lib libxcb $(get_install_dir libxcb)
  fi
}
