# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present EmuELEC (https://github.com/emuelec)

PKG_NAME="munt_alsadrv"
PKG_VERSION="$(get_pkg_version munt)"
PKG_NEED_UNPACK="$(get_pkg_directory munt)"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/munt/munt"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain munt"
PKG_LONGDESC="A software synthesiser emulating pre-GM MIDI devices such as the Roland MT-32."
PKG_TOOLCHAIN="make"

unpack() {
  ${SCRIPTS}/get munt
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/munt/munt-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}
                    
make_target() {
cd ${PKG_BUILD}/mt32emu_alsadrv
make mt32d
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/
  cp ${PKG_BUILD}/mt32emu_alsadrv/mt32d ${INSTALL}/usr/bin/
}
