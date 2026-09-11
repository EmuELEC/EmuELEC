# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present EmuELEC Team (https://github.com/EmuELEC/EmuELEC)

PKG_NAME="tcl"
PKG_VERSION="8.6.16"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="BSD"
PKG_SITE="https://www.tcl.tk"
PKG_URL="https://prdownloads.sourceforge.net/tcl/tcl${PKG_VERSION}-src.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_SHORTDESC="Tcl: Tool Command Language"
PKG_TOOLCHAIN="manual"

make_target() {
  cd ${PKG_BUILD}/unix
  ./configure \
    --host=${TARGET_NAME} \
    --prefix=/usr \
    --enable-shared \
    --disable-symbols \
    --without-tzdata \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}" \
    RANLIB="${RANLIB}" \
    CFLAGS="${TARGET_CFLAGS}" \
    LDFLAGS="${TARGET_LDFLAGS}"
  make
}

makeinstall_target() {
  make -C ${PKG_BUILD}/unix DESTDIR=${INSTALL} install
  # Also install headers + libs to sysroot for cross-compilation of
  # dependent packages (e.g. openMSX).
  make -C ${PKG_BUILD}/unix DESTDIR=${SYSROOT_PREFIX} install

  # Tcl 8.6 does not install a pkg-config .pc file by default.
  # Create one so probe.py can discover the link flags (-ltcl8.6).
  # Without it, probe.py finds tcl.h but links with no -l flag and fails.
  local pc_dir="${SYSROOT_PREFIX}/usr/lib/pkgconfig"
  mkdir -p "${pc_dir}"
  cat > "${pc_dir}/tcl.pc" << TCPC
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: Tcl
Description: Tool Command Language
Version: ${PKG_VERSION}
Libs: -L\${libdir} -ltcl8.6
Libs.private: -ldl -lpthread -lz -lm
Cflags: -I\${includedir}
TCPC

  rm -rf ${INSTALL}/usr/share/man
  rm -rf ${INSTALL}/usr/bin/tclsh*
}