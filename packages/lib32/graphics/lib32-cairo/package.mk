# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-cairo"
PKG_VERSION="$(get_pkg_version cairo)"
PKG_NEED_UNPACK="$(get_pkg_directory cairo)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="http://cairographics.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-zlib lib32-freetype lib32-fontconfig lib32-glib lib32-libpng lib32-pixman lib32-${OPENGLES}"
PKG_PATCH_DIRS+=" $(get_pkg_directory cairo)/patches"
PKG_LONGDESC="Cairo is a vector graphics library with cross-device output support."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-silent-rules \
                            --enable-shared \
                            --disable-static \
                            --disable-gtk-doc \
                            --enable-largefile \
                            --enable-atomic \
                            --disable-gcov \
                            --disable-valgrind \
                            --disable-xcb \
                            --disable-xlib-xcb \
                            --disable-xcb-shm \
                            --disable-qt \
                            --disable-quartz \
                            --disable-quartz-font \
                            --disable-quartz-image \
                            --disable-win32 \
                            --disable-win32-font \
                            --disable-os2 \
                            --disable-beos \
                            --disable-cogl \
                            --disable-drm \
                            --disable-gallium \
                            --enable-png \
                            --disable-directfb \
                            --disable-vg \
                            --disable-wgl \
                            --disable-script \
                            --enable-ft \
                            --enable-fc \
                            --enable-ps \
                            --enable-pdf \
                            --enable-svg \
                            --disable-test-surfaces \
                            --disable-tee \
                            --disable-xml \
                            --enable-pthread \
                            --enable-gobject=yes \
                            --disable-full-testing \
                            --disable-rpath \
                            --disable-trace \
                            --enable-interpreter \
                            --disable-symbol-lookup \
                            --enable-some-floating-point \
                            --with-gnu-ld \
                            --disable-xlib \
                            --disable-xlib-xrender \
                            --without-x \
                            --disable-gl \
                            --disable-glx \
                            --enable-glesv2 \
                            --enable-egl"

unpack() {
  ${SCRIPTS}/get cairo
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/cairo/cairo-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
