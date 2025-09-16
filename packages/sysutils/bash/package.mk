# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="bash"
PKG_VERSION="5.2.15"
PKG_SHA256="13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"
PKG_LICENSE="GPL"
PKG_SITE="https://www.gnu.org/software/bash/"
PKG_URL="https://ftp.gnu.org/gnu/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses readline"
PKG_LONGDESC="Bash is the GNU Project shell - the Bourne Again SHell."
PKG_NEED_UNPACK="$(get_pkg_directory busybox)"

PKG_CONFIGURE_OPTS_TARGET="--with-curses \
                           --without-bash-malloc \
                           --with-installed-readline \
                             bash_cv_getcwd_malloc=yes \
                             bash_cv_printf_a_format=yes \
                             bash_cv_func_sigsetjmp=present \
                             bash_cv_sys_named_pipes=present"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp bash  ${INSTALL}/usr/bin
}

post_makeinstall_target() {
  ln -sf /usr/bin/bash ${INSTALL}/usr/bin/sh
}
