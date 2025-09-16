# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="util-linux"
PKG_VERSION="2.38.1"
PKG_SHA256="60492a19b44e6cf9a3ddff68325b333b8b52b6c59ce3ebd6a0ecaa4c5117e84f"
PKG_LICENSE="GPL"
PKG_URL="https://www.kernel.org/pub/linux/utils/util-linux/v$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host autoconf:host automake:host intltool:host libtool:host pkg-config:host"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_DEPENDS_INIT="toolchain"
PKG_LONGDESC="A large variety of low-level system utilities that are necessary for a Linux system to function."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic:host"

UTILLINUX_CONFIG_DEFAULT="--disable-gtk-doc \
                          --disable-nls \
                          --disable-rpath \
                          --enable-tls \
                          --enable-chsh-only-listed \
                          --disable-bash-completion \
                          --disable-colors-default \
                          --disable-pylibmount \
                          --disable-pg-bell \
                          --disable-use-tty-group \
                          --disable-makeinstall-chown \
                          --disable-makeinstall-setuid \
                          --with-gnu-ld \
                          --without-selinux \
                          --without-audit \
                          --without-udev \
                          --without-ncurses \
                          --without-ncursesw \
                          --without-readline \
                          --without-slang \
                          --without-tinfo \
                          --without-utempter \
                          --without-util \
                          --without-libz \
                          --without-user \
                          --without-systemd \
                          --without-smack \
                          --without-python \
                          --without-systemdsystemunitdir"

PKG_CONFIGURE_OPTS_TARGET="${UTILLINUX_CONFIG_DEFAULT} \
                           --disable-all-programs \
                           --enable-libuuid \
                           --enable-libblkid \
                           --enable-libmount \
                           --enable-libsmartcols \
                           --enable-losetup \
                           --enable-fsck \
                           --enable-fstrim \
                           --enable-blkid \
                           --enable-lsfd \
                           --disable-setterm \
                           --with-ncursesw"

if [ "${SWAP_SUPPORT}" = "yes" ]; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-swapon"
fi

PKG_CONFIGURE_OPTS_HOST="--enable-static \
                         --disable-shared \
                         --enable-all-programs \
                         ${UTILLINUX_CONFIG_DEFAULT} \
                         --enable-uuidgen \
                         --enable-libuuid"

PKG_CONFIGURE_OPTS_INIT="${UTILLINUX_CONFIG_DEFAULT} \
                         --disable-all-programs \
                         --enable-libblkid \
                         --enable-libmount \
                         --enable-fsck"

if [ "${INITRAMFS_PARTED_SUPPORT}" = "yes" ]; then
  PKG_CONFIGURE_OPTS_INIT+=" --enable-mkfs --enable-libuuid"
fi

post_makeinstall_target() {
  if [ "${SWAP_SUPPORT}" = "yes" ]; then
    mkdir -p ${INSTALL}/usr/lib/libreelec
      cp -PR ${PKG_DIR}/scripts/mount-swap ${INSTALL}/usr/lib/libreelec

    mkdir -p ${INSTALL}/etc
      cat ${PKG_DIR}/config/swap.conf | \
        sed -e "s,@SWAPFILESIZE@,${SWAPFILESIZE},g" \
            -e "s,@SWAP_ENABLED_DEFAULT@,${SWAP_ENABLED_DEFAULT},g" \
            > ${INSTALL}/etc/swap.conf
  fi
}

post_install () {
  if [ "${SWAP_SUPPORT}" = "yes" ]; then
    enable_service swap.service
  fi

  enable_service fstrim.timer
}
