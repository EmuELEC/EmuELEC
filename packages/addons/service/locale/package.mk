# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="locale"
PKG_REV="0"
PKG_ARCH="any"
PKG_DEPENDS_TARGET="toolchain glibc"
PKG_SECTION="service"
PKG_SHORTDESC="Locale: allows users to set a custom locale to override the POSIX default"
PKG_LONGDESC="Locale (${PKG_REV}) allows users to set a custom locale in the OS to override the POSIX default"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Locale"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p "${ADDON_BUILD}/${PKG_ADDON_ID}/bin"
  cp -PR "$(get_install_dir glibc)/.noinstall/localedef" \
         "${ADDON_BUILD}/${PKG_ADDON_ID}/bin"

  mkdir -p "${ADDON_BUILD}/${PKG_ADDON_ID}/i18n"
  cp -PR "$(get_install_dir glibc)/.noinstall/charmaps" \
         "$(get_install_dir glibc)/.noinstall/locales" \
         "${ADDON_BUILD}/${PKG_ADDON_ID}/i18n"

  mkdir -p "${ADDON_BUILD}/${PKG_ADDON_ID}/locpath"

  cp -PR ${PKG_DIR}/resources ${ADDON_BUILD}/${PKG_ADDON_ID}

  locales=""
  for p in "${ADDON_BUILD}/${PKG_ADDON_ID}/i18n/locales"/*; do
    l="$(basename ${p})"
    if [ "${l}" = "POSIX" ]; then
      continue
    fi
    locales+="$(echo -e '\\\n              <option>'"${l}"'</option>')"
  done

  sed -e "s|@LOCALES@|${locales}|" \
      -i ${ADDON_BUILD}/${PKG_ADDON_ID}/resources/settings.xml
}
