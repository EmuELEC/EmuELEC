# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="muntalsa"
PKG_VERSION="1cdac309f420ca224e59e2952f5521759508d2eb"
PKG_SHA256="cad4c7b224f315051e01a8c6b27b42941fc1818766c3c69df773e788bc39f0b6"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/munt/munt"
PKG_URL="https://github.com/munt/munt/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="make"
PKG_LONGDESC="A software synthesiser emulating pre-GM MIDI devices such as the Roland MT-32."

make_target() {
cd ${PKG_BUILD}
cd mt32emu_alsadrv
make mt32d
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/
  cp mt32d ${INSTALL}/usr/bin/
}
