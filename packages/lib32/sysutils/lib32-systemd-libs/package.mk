# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-systemd-libs"
PKG_VERSION="$(get_pkg_version systemd)"
PKG_NEED_UNPACK="$(get_pkg_directory systemd)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL2.1+"
PKG_SITE="http://www.freedesktop.org/wiki/Software/systemd"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain Jinja2:host lib32-libcap lib32-util-linux"
SD_DIRECTORY="$(get_pkg_directory systemd)"
PKG_PATCH_DIRS+=" ${SD_DIRECTORY}/patches"
PKG_LONGDESC="A system and session manager for Linux, compatible with SysV and LSB init scripts."
PKG_BUILD_FLAGS="lib32"

if [ "${DEVICE}" = "Amlogic-old" ]; then
  PKG_PATCH_DIRS+=" ${SD_DIRECTORY}/patches/amlogic"
fi

PKG_MESON_OPTS_TARGET="--libdir=/usr/lib \
                       -Drootprefix=/usr \
                       -Dsplit-usr=false \
                       -Dsplit-bin=true \
                       -Ddefault-hierarchy=unified \
                       -Dtty-gid=5 \
                       -Dtests=false \
                       -Dseccomp=false \
                       -Dselinux=false \
                       -Dapparmor=false \
                       -Dpolkit=false \
                       -Dacl=false \
                       -Daudit=false \
                       -Dblkid=true \
                       -Dkmod=false \
                       -Dpam=false \
                       -Dmicrohttpd=false \
                       -Dlibcryptsetup=false \
                       -Dlibcurl=false \
                       -Dlibidn=false \
                       -Dlibidn2=false \
                       -Dlibiptc=false \
                       -Dqrencode=false \
                       -Dgcrypt=false \
                       -Dgnutls=false \
                       -Dopenssl=false 
                       -Delfutils=false \
                       -Dzlib=false \
                       -Dbzip2=false \
                       -Dxz=false \
                       -Dlz4=false \
                       -Dxkbcommon=false \
                       -Dpcre2=false \
                       -Dglib=false \
                       -Ddbus=false \
                       -Ddefault-dnssec=no \
                       -Dimportd=false \
                       -Dremote=false \
                       -Dutmp=true \
                       -Dhibernate=false \
                       -Denvironment-d=false \
                       -Dbinfmt=false \
                       -Dcoredump=false \
                       -Dresolve=false \
                       -Dlogind=true \
                       -Dhostnamed=true \
                       -Dlocaled=false \
                       -Dmachined=false \
                       -Dportabled=false \
                       -Dnetworkd=false \
                       -Dtimedated=false \
                       -Dtimesyncd=true \
                       -Dfirstboot=false \
                       -Drandomseed=false \
                       -Dbacklight=false \
                       -Dvconsole=false \
                       -Dquotacheck=false \
                       -Dsysusers=false \
                       -Dtmpfiles=true \
                       -Dhwdb=true \
                       -Drfkill=false \
                       -Dldconfig=false \
                       -Defi=false \
                       -Dtpm=false \
                       -Dima=false \
                       -Dsmack=false \
                       -Dgshadow=false \
                       -Didn=false \
                       -Dnss-myhostname=false \
                       -Dnss-mymachines=false \
                       -Dnss-resolve=false \
                       -Dnss-systemd=false \
                       -Dman=false \
                       -Dhtml=false \
                       -Dlink-udev-shared=true \
                       -Dlink-systemctl-shared=true \
                       -Dbashcompletiondir=no \
                       -Dzshcompletiondir=no \
                       -Dkmod-path=/usr/bin/kmod \
                       -Dmount-path=/usr/bin/mount \
                       -Dumount-path=/usr/bin/umount \
                       -Ddebug-tty=${DEBUG_TTY} \
                       -Dpkgconfigdatadir=/usr/lib/pkgconfig \
                       -Dversion-tag=${PKG_VERSION}"

if [ "${DEVICE}" != "Amlogic-old" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dfdisk=false \
                           -Dhomed=false \
                           -Dlink-networkd-shared=false \
                           -Dp11kit=false \
                           -Dpwquality=false \
                           -Drepart=false \
                           -Duserdb=false"
fi

unpack() {
  ${SCRIPTS}/get systemd
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/systemd/systemd-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -fno-schedule-insns -fno-schedule-insns2 -Wno-format-truncation"
  export LC_ALL=en_US.UTF-8
}

make_target() {
  local LIBSYSTEMD_VERSION=$(grep "^libsystemd_version = '[0-9]\+\.[0-9]\+\.[0-9]\+'" "${PKG_BUILD}/meson.build" | awk -F "'" '{print $2}')
  local LIBUDEV_VERSION=$(grep "^libudev_version = '[0-9]\+\.[0-9]\+\.[0-9]\+'" "${PKG_BUILD}/meson.build" | awk -F "'" '{print $2}')
  if [ "${DEVICE}" = "Amlogic-old" ]; then
    LIBUDEV_TARGET=src/udev/libudev.so.${LIBUDEV_VERSION}
    local PC_TARGETS=""
  else
    LIBUDEV_TARGET=libudev.so.${LIBUDEV_VERSION}
    local PC_TARGETS="src/libudev/libudev.pc \
                      src/libsystemd/libsystemd.pc"
  fi
  LIBSYSTEMD_TARGET=libsystemd.so.${LIBSYSTEMD_VERSION}
  ninja ${NINJA_OPTS} ${LIBUDEV_TARGET} \
                      ${LIBSYSTEMD_TARGET} \
                      ${PC_TARGETS}
                      
  ${TARGET_PREFIX}strip ${LIBUDEV_TARGET} \
                        ${LIBSYSTEMD_TARGET}
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib32"
  mkdir -p "${SYSROOT_PREFIX}/usr/lib"
    local i
    for i in ${LIBUDEV_TARGET%%.so*}.so* ${LIBSYSTEMD_TARGET%%.so*}.so*; do 
      if [ "${i: -1}" = 'p' ]; then
        continue
      fi
      cp -va "${i}" "${INSTALL}/usr/lib32/"
      cp -va "${i}" "${SYSROOT_PREFIX}/usr/lib/"
    done
  mkdir -p "${SYSROOT_PREFIX}/usr/include/systemd"
    cp -va "../src/libudev/libudev.h" "${SYSROOT_PREFIX}/usr/include/"
    cp -va "../src/systemd/_sd-common.h" "${SYSROOT_PREFIX}/usr/include/systemd/"
    for i in bus-protocol \
             bus-vtable \
             bus \
             daemon \
             device \
             event \
             hwdb \
             id128 \
             journal \
             login \
             messages \
             path; do
      cp -va "../src/systemd/sd-${i}.h" "${SYSROOT_PREFIX}/usr/include/systemd/"
    done
  mkdir -p "${SYSROOT_PREFIX}/usr/lib/pkgconfig"
    cp -va "src/libudev/libudev.pc" "src/libsystemd/libsystemd.pc"  "${SYSROOT_PREFIX}/usr/lib/pkgconfig/"
}
