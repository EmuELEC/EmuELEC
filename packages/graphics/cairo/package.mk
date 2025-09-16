# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="cairo"
PKG_VERSION="1.17.6"
PKG_SHA256="4eebc4c2bad0402bc3f501db184417094657d111fb6c06f076a82ea191fe1faf"
PKG_LICENSE="LGPL"
PKG_SITE="https://cairographics.org/"
PKG_URL="https://download.gnome.org/sources/cairo/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib freetype fontconfig glib libpng pixman"
PKG_LONGDESC="Cairo is a vector graphics library with cross-device output support."
PKG_TOOLCHAIN="configure"

configure_package() {
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" libXrender libX11 mesa"
  fi

  if [ "${OPENGL_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
  elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi
}

pre_configure_target() {
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
                             --with-gnu-ld"

  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_CONFIGURE_OPTS_TARGET+=" --x-includes="${SYSROOT_PREFIX}/usr/include" \
                                 --x-libraries="${SYSROOT_PREFIX}/usr/lib" \
                                 --enable-xlib \
                                 --enable-xlib-xrender \
                                 --with-x"
  else
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-xlib \
                                 --disable-xlib-xrender \
                                 --without-x"
  fi

  if [ "${OPENGL_SUPPORT}" = "yes" ]; then
    PKG_CONFIGURE_OPTS_TARGET+=" --enable-gl \
                                 --enable-glx \
                                 --disable-glesv2 \
                                 --disable-egl"
  elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-gl \
                                 --disable-glx \
                                 --enable-glesv2 \
                                 --enable-egl"
  else
    PKG_CONFIGURE_OPTS_TARGET+=" --disable-gl \
                                 --disable-glx \
                                 --disable-glesv2 \
                                 --disable-egl"
  fi
}

post_configure_target() {
  libtool_remove_rpath libtool
}
