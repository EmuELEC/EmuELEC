# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="json-glib"
PKG_VERSION="1.6.6"
PKG_SHA256="bf4d1cd6c343ce13b9258e6703a0411a3b659887b65877e85a2aa488ae18b865"
PKG_LICENSE="LGPL-2.1"
PKG_SITE="https://github.com/GNOME/json-glib"
PKG_URL="https://github.com/GNOME/json-glib/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib glib:host"
PKG_LONGDESC="JSON-GLib implements a full suite of JSON-related tools using GLib and GObject."

PKG_MESON_OPTS_TARGET="-Dintrospection=disabled \
                       -Dgtk_doc=disabled \
                       -Dman=false \
                       -Dtests=false"
