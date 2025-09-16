# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ir-bpf-decoders"
PKG_VERSION="1.22.0"
PKG_SHA256="9743e49dd725f9fb7d0410f3481931156d69fd8305184baa883ed94038fc79fc"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://linuxtv.org/"
PKG_URL="https://github.com/LibreELEC/ir-bpf-decoders/archive/v4l-utils-${PKG_VERSION}.tar.gz"
PKG_LONGDESC="ir-bpf-decoders: precompiled binaries of IR BPF decoders from v4l-utils utils/keytable/bpf_protocols"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/udev/rc_keymaps/protocols
  cp ${PKG_BUILD}/*.o ${INSTALL}/usr/lib/udev/rc_keymaps/protocols
}
