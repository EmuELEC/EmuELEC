# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="eemount"
PKG_VERSION="7ec126a4dc2209eaa5c7cc25cd5e227b6157ae41"
PKG_SHA256="4895c70bff8a3a9e1046d924cca71eadf5cb1774b63c2e48bab05635e26c690b"
PKG_SITE="https://github.com/shantigilbert/eemount"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="Multi-source ROMs mounting utility for EmuELEC"
PKG_TOOLCHAIN="make"
PKG_MAKE_OPTS_TARGET="LOGGING_ALL_TO_STDOUT=1"
