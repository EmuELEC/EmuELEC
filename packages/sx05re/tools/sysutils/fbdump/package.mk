# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbdump"
PKG_VERSION="0.4.2"
PKG_SHA256="c4d521a86229b3106cf69786008ad94f899da5288a19a067deae84951880722d"
PKG_LICENSE="GPL"
PKG_SITE="http://www.rcdrummond.net/fbdump"
PKG_URL="${PKG_SITE}/fbdump-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="fbdump is a simple tool that captures the contents of the visible portion of the Linux framebuffer device and writes it to the standard output as a PPM file."
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
# for some reason this was failing with undefined reference to 'rpl_malloc' so we remove the check
cd ${PKG_BUILD}
sed -i "s|AC_FUNC_MALLOC||" configure.in
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp src/fbdump ${INSTALL}/usr/bin
}
