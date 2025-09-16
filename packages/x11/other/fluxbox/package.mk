# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="fluxbox"
# dont bump or go back to ratpoison then f*** all 3rdparty stuff.
PKG_VERSION="1.3.7"
PKG_SHA256="fc8c75fe94c54ed5a5dd3fd4a752109f8949d6df67a48e5b11a261403c382ec0"
PKG_LICENSE="OSS"
PKG_SITE="http://fluxbox.org/"
PKG_URL="http://sourceforge.net/projects/fluxbox/files/fluxbox/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libX11 libXrandr libXext libXrender"
PKG_LONGDESC="Fluxbox is a windowmanager for X that was based on the Blackbox 0.61.1 code."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_func_realloc_0_nonnull=yes \
                           ac_cv_func_malloc_0_nonnull=yes \
                           --disable-toolbar \
                           --disable-slit \
                           --disable-systray \
                           --enable-ewmh \
                           --disable-xpm \
                           --disable-xft \
                           --disable-fribidi \
                           --disable-debug \
                           --disable-test \
                           --disable-nls \
                           --disable-imlib2"

post_install() {
  enable_service windowmanager.service
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin/fbrun
  rm -rf ${INSTALL}/usr/bin/fbsetbg
  rm -rf ${INSTALL}/usr/bin/fluxbox-generate_menu
  rm -rf ${INSTALL}/usr/bin/fluxbox-remote
  rm -rf ${INSTALL}/usr/bin/startfluxbox

  rm -rf ${INSTALL}/usr/share/fluxbox/styles

  cp ${PKG_DIR}/config/apps ${INSTALL}/usr/share/fluxbox/
  cp ${PKG_DIR}/config/init ${INSTALL}/usr/share/fluxbox/
  cp ${PKG_DIR}/config/keys ${INSTALL}/usr/share/fluxbox/
}
