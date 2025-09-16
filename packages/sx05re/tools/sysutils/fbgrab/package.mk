# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbgrab"
PKG_VERSION="74373aafc0b496e67642562d86eac6b858a31f24"
PKG_SHA256="c6199223c001bb47950a157be9877f54b20211cacd05c0256a08769e9fe0f190"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/GunnarMonell/fbgrab"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng fbdump"
PKG_LONGDESC="fbgrab linux framebuffer screenshot utility. "
PKG_TOOLCHAIN="make"

pre_configure_target() {
	sed -i "s|-Wall|-Wall -lm|" Makefile
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp fbgrab ${INSTALL}/usr/bin
cp screenshot.sh ${INSTALL}/usr/bin
}
