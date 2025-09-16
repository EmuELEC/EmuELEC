# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="Python3"
# When changing PKG_VERSION remember to sync PKG_PYTHON_VERSION!
PKG_VERSION="3.11.2"
PKG_SHA256="29e4b8f5f1658542a8c13e2dd277358c9c48f2b2f7318652ef1675e402b9d2af"
PKG_LICENSE="OSS"
PKG_SITE="https://www.python.org/"
PKG_URL="https://www.python.org/ftp/python/${PKG_VERSION}/${PKG_NAME::-1}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="zlib:host bzip2:host libffi:host util-linux:host xz:host autoconf-archive:host"
PKG_DEPENDS_TARGET="toolchain Python3:host sqlite expat zlib bzip2 xz openssl libffi readline ncurses util-linux"
PKG_LONGDESC="Python3 is an interpreted object-oriented programming language."
PKG_TOOLCHAIN="autotools"

PKG_PYTHON_VERSION="python3.11"

PKG_PY_DISABLED_MODULES="_tkinter nis gdbm bsddb ossaudiodev"

PKG_CONFIGURE_OPTS_HOST="ac_cv_prog_HAS_HG=/bin/false
                         ac_cv_prog_SVNVERSION=/bin/false
                         --disable-pyc-build
                         --disable-ossaudiodev
                         --disable-sqlite3
                         --disable-codecs-cjk
                         --disable-nis
                         --enable-unicodedata
                         --enable-openssl
                         --disable-readline
                         --disable-bzip2
                         --enable-zlib
                         --enable-xz
                         --disable-tk
                         --disable-curses
                         --disable-pydoc
                         --disable-test-modules
                         --disable-lib2to3
                         --disable-idle3
                         --without-cxx-main
                         --with-expat=builtin
                         --with-libmpdec=none
                         --with-doc-strings
                         --with-system-ffi
                         --without-pymalloc
                         --without-ensurepip
"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_prog_HAS_HG=/bin/false
                           ac_cv_prog_SVNVERSION=/bin/false
                           ac_cv_file__dev_ptmx=no
                           ac_cv_file__dev_ptc=no
                           ac_cv_have_long_long_format=yes
                           ac_cv_working_tzset=yes
                           ac_cv_func_lchflags_works=no
                           ac_cv_func_chflags_works=no
                           ac_cv_func_printf_zd=yes
                           ac_cv_buggy_getaddrinfo=no
                           ac_cv_header_bluetooth_bluetooth_h=no
                           ac_cv_header_bluetooth_h=no
                           --disable-pyc-build
                           --disable-ossaudiodev
                           --enable-sqlite3
                           --disable-codecs-cjk
                           --disable-nis
                           --enable-unicodedata
                           --enable-openssl
                           --enable-readline
                           --enable-bzip2
                           --enable-zlib
                           --enable-xz
                           --disable-tk
                           --enable-curses
                           --disable-pydoc
                           --disable-test-modules
                           --disable-lib2to3
                           --disable-idle3
                           --without-cxx-main
                           --with-expat=system
                           --with-libmpdec=none
                           --with-doc-strings
                           --with-system-ffi
                           --without-pymalloc
                           --without-ensurepip
                           --enable-ipv6
                           --with-build-python=${TOOLCHAIN}/bin/python
"

pre_configure_host() {
  export PYTHON_MODULES_INCLUDE="${HOST_INCDIR}"
  export PYTHON_MODULES_LIB="${HOST_LIBDIR}"
  export DISABLED_EXTENSIONS="readline _curses _curses_panel ${PKG_PY_DISABLED_MODULES}"
}

post_make_host() {
  # python distutils per default adds -L${LIBDIR} when linking binary extensions
  sed -e "s|^ 'LIBDIR':.*| 'LIBDIR': '/usr/lib',|g" -i $(find ${PKG_BUILD}/.${HOST_NAME} -not -path '*/__pycache__/*' -name '_sysconfigdata__*.py')
}

post_makeinstall_host() {
  ln -sf ${PKG_PYTHON_VERSION} ${TOOLCHAIN}/bin/python

  rm -f ${TOOLCHAIN}/bin/smtpd.py*
  rm -f ${TOOLCHAIN}/bin/pyvenv
  rm -f ${TOOLCHAIN}/bin/pydoc*

  rm -fr ${PKG_BUILD}/.${HOST_NAME}/build/temp.*

  cp ${PKG_BUILD}/Tools/scripts/reindent.py ${TOOLCHAIN}/lib/${PKG_PYTHON_VERSION}
}

pre_configure_target() {
  export PYTHON_MODULES_INCLUDE="${TARGET_INCDIR}"
  export PYTHON_MODULES_LIB="${TARGET_LIBDIR}"
  export DISABLED_EXTENSIONS="${PKG_PY_DISABLED_MODULES}"
}

post_makeinstall_target() {
  ln -sf ${PKG_PYTHON_VERSION} ${INSTALL}/usr/bin/python

  rm -fr ${PKG_BUILD}/.${TARGET_NAME}/build/temp.*

  PKG_INSTALL_PATH_LIB=${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}

  for dir in config compiler sysconfigdata lib-dynload/sysconfigdata lib2to3/tests test; do
    rm -rf ${PKG_INSTALL_PATH_LIB}/${dir}
  done

  rm -rf ${PKG_INSTALL_PATH_LIB}/distutils/command/*.exe

  rm -rf ${INSTALL}/usr/bin/pyvenv
  rm -rf ${INSTALL}/usr/bin/python*-config
  rm -rf ${INSTALL}/usr/bin/smtpd.py ${INSTALL}/usr/bin/smtpd.py.*

  find ${INSTALL} -name '*.o' -delete

  python_compile ${PKG_INSTALL_PATH_LIB}

  # strip
  chmod u+w ${INSTALL}/usr/lib/libpython*.so.*
  debug_strip ${INSTALL}/usr
}
