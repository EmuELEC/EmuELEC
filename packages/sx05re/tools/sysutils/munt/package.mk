# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="munt"
PKG_VERSION="1cdac309f420ca224e59e2952f5521759508d2eb"
PKG_SHA256="cad4c7b224f315051e01a8c6b27b42941fc1818766c3c69df773e788bc39f0b6"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/munt/munt"
PKG_URL="https://github.com/munt/munt/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A software synthesiser emulating pre-GM MIDI devices such as the Roland MT-32."

make_target() {
cd ${PKG_BUILD}/mt32emu_alsadrv
make mt32d

cd ${PKG_BUILD}/mt32emu
cmake -DCMAKE_BUILD_TYPE:STRING=Release .
make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/
  mkdir -p ${INSTALL}/usr/lib/
  cp ${PKG_BUILD}/mt32emu_alsadrv/mt32d ${INSTALL}/usr/bin/
  cp ${PKG_BUILD}/mt32emu/libmt32emu* ${INSTALL}/usr/lib/
}
