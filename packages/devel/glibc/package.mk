# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glibc"
PKG_VERSION="2.36"
PKG_SHA256="1c959fea240906226062cb4b1e7ebce71a9f0e3c0836c09e7e3423d434fcfe75"
PKG_LICENSE="GPL"
PKG_SITE="https://www.gnu.org/software/libc/"
PKG_URL="https://ftp.gnu.org/pub/gnu/glibc/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="ccache:host autotools:host linux:host gcc:bootstrap pigz:host Python3:host"
PKG_DEPENDS_INIT="glibc"
PKG_LONGDESC="The Glibc package contains the main C library."
PKG_BUILD_FLAGS="+bfd"

case "${LINUX}" in
  amlogic-4.9|rk356x-4.19|OdroidM1-4.19)
    OPT_ENABLE_KERNEL=4.9.0
    ;;
  gameforce-4.4|rockchip-4.4|odroid-go-a-4.4)
    OPT_ENABLE_KERNEL=4.4.0
    ;;
  amlogic-5.4)
    OPT_ENABLE_KERNEL=5.4.0
    ;;
  amlogic-5.15)
    OPT_ENABLE_KERNEL=5.15.0
    ;;
  amlogic-3.14)
    OPT_ENABLE_KERNEL=3.0.0
    ;;
  *)
    OPT_ENABLE_KERNEL=6.1.0
    ;;
esac

if [ "${TARGET_ARCH}" = "arm" ] || [ "${TARGET_ARCH}" = "aarch64" ]; then
  PKG_PATCH_DIRS="widevine-arm"
fi

PKG_CONFIGURE_OPTS_TARGET="BASH_SHELL=/bin/sh \
                           ac_cv_path_PERL=no \
                           ac_cv_prog_MAKEINFO= \
                           --libexecdir=/usr/lib/glibc \
                           --cache-file=config.cache \
                           --disable-profile \
                           --disable-sanity-checks \
                           --enable-add-ons \
                           --enable-bind-now \
                           --with-elf \
                           --with-tls \
                           --with-__thread \
                           --with-binutils=${BUILD}/toolchain/bin \
                           --with-headers=${SYSROOT_PREFIX}/usr/include \
                           --enable-kernel=${OPT_ENABLE_KERNEL} \
                           --without-cvs \
                           --without-gd \
                           --disable-build-nscd \
                           --disable-nscd \
                           --disable-timezone-tools"

if build_with_debug; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-debug"
else
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-debug"
fi

post_unpack() {
  find "${PKG_BUILD}" -type f -name '*.py' -exec sed -e '1s,^#![[:space:]]*/usr/bin/python.*,#!/usr/bin/env python3,' -i {} \;
}

pre_configure_target() {
# Filter out some problematic *FLAGS
  export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-ffast-math||g")
  export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-Ofast|-O2|g")
  export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-O.|-O2|g")

  export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-Wunused-but-set-variable||g")
  export CFLAGS="${CFLAGS} -Wno-unused-variable"

  if [ -n "${PROJECT_CFLAGS}" ]; then
    export CFLAGS=$(echo ${CFLAGS} | sed -e "s|${PROJECT_CFLAGS}||g")
  fi

  export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-ffast-math||g")
  export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-Ofast|-O2|g")
  export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-O.|-O2|g")

  export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-Wl,--as-needed||")

  unset LD_LIBRARY_PATH

  # set some CFLAGS we need
  export CFLAGS="${CFLAGS} -g -fno-stack-protector"

  export BUILD_CC=${HOST_CC}
  export OBJDUMP_FOR_HOST=objdump

  cat >config.cache <<EOF
libc_cv_forced_unwind=yes
libc_cv_c_cleanup=yes
libc_cv_ssp=no
libc_cv_ssp_strong=no
libc_cv_slibdir=/usr/lib
EOF

  cat >configparms <<EOF
libdir=/usr/lib
slibdir=/usr/lib
sbindir=/usr/bin
rootsbindir=/usr/bin
build-programs=yes
EOF

  # binaries to install into target
  GLIBC_INCLUDE_BIN="getent ldd locale localedef"
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/.noinstall
    cp -p ${INSTALL}/usr/bin/localedef ${INSTALL}/.noinstall
    cp -a ${INSTALL}/usr/share/i18n/locales ${INSTALL}/.noinstall
    mv ${INSTALL}/usr/share/i18n/charmaps ${INSTALL}/.noinstall

# cleanup
# remove any programs we don't want/need, keeping only those we want
  for f in $(find ${INSTALL}/usr/bin -type f); do
    listcontains "${GLIBC_INCLUDE_BIN}" "$(basename "${f}")" || safe_remove "${f}"
  done

  safe_remove ${INSTALL}/usr/lib/audit
  safe_remove ${INSTALL}/usr/lib/glibc
  safe_remove ${INSTALL}/usr/lib/*.o
  safe_remove ${INSTALL}/var

# add UTF-8 charmap
  mkdir -p ${INSTALL}/usr/share/i18n/charmaps
    cp -PR ${INSTALL}/.noinstall/charmaps/UTF-8.gz ${INSTALL}/usr/share/i18n/charmaps

  if [ ! "${GLIBC_LOCALES}" = yes ]; then
    safe_remove ${INSTALL}/usr/share/i18n/locales

    mkdir -p ${INSTALL}/usr/share/i18n/locales
      cp -PR ${PKG_BUILD}/localedata/locales/POSIX ${INSTALL}/usr/share/i18n/locales
  fi

# create default configs
  mkdir -p ${INSTALL}/etc
    cp ${PKG_DIR}/config/nsswitch-target.conf ${INSTALL}/etc/nsswitch.conf
    cp ${PKG_DIR}/config/host.conf ${INSTALL}/etc
    cp ${PKG_DIR}/config/gai.conf ${INSTALL}/etc
}

configure_init() {
  cd ${PKG_BUILD}
    rm -rf ${PKG_BUILD}/.${TARGET_NAME}-init
}

make_init() {
  : # reuse make_target()
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/elf/ld*.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/libc.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/math/libm.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/nptl/libpthread.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/rt/librt.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/resolv/libnss_dns.so* ${INSTALL}/usr/lib
    cp -PR ${PKG_BUILD}/.${TARGET_NAME}/resolv/libresolv.so* ${INSTALL}/usr/lib
}

post_makeinstall_init() {
# create default configs
  mkdir -p ${INSTALL}/etc
    cp ${PKG_DIR}/config/nsswitch-init.conf ${INSTALL}/etc/nsswitch.conf
}
