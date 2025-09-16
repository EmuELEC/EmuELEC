# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="syslinux"
PKG_VERSION="6.03"
PKG_SHA256="26d3986d2bea109d5dc0e4f8c4822a459276cf021125e8c9f23c3cca5d8c850e"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL"
PKG_SITE="http://syslinux.zytor.com/"
PKG_URL="http://www.kernel.org/pub/linux/utils/boot/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="util-linux:host"
PKG_DEPENDS_TARGET="toolchain util-linux e2fsprogs syslinux:host"
PKG_LONGDESC="The SYSLINUX project covers lightweight linux bootloaders."

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="CC=${CC} AR=${AR} RANLIB=${RANLIB} installer"

# Unset all compiler FLAGS
  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS
}

pre_build_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

pre_build_host() {
  mkdir -p ${PKG_BUILD}/.${HOST_NAME}
  cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}
}

pre_make_target() {
  cd .${TARGET_NAME}
}

pre_make_host() {
  cd .${HOST_NAME}
}

make_host() {
  make CC=${CC} \
       AR=${AR} \
       RANLIB=${RANLIB} \
       CFLAGS="-I${TOOLCHAIN}/include -I${PKG_BUILD}/libinstaller -I${PKG_BUILD}/libfat -I${PKG_BUILD}/bios -I${PKG_BUILD}/utils -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" \
       LDFLAGS="-L${TOOLCHAIN}/lib" \
       installer
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp bios/linux/syslinux ${TOOLCHAIN}/bin
    cp bios/mtools/syslinux ${TOOLCHAIN}/bin/syslinux.mtools

  mkdir -p ${TOOLCHAIN}/share/syslinux
    cp bios/mbr/mbr.bin ${TOOLCHAIN}/share/syslinux
    cp bios/mbr/gptmbr.bin ${TOOLCHAIN}/share/syslinux
    cp efi64/efi/syslinux.efi ${TOOLCHAIN}/share/syslinux/bootx64.efi
    cp efi64/com32/elflink/ldlinux/ldlinux.e64  ${TOOLCHAIN}/share/syslinux
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp bios/linux/syslinux ${INSTALL}/usr/bin

  ${STRIP} ${INSTALL}/usr/bin/syslinux

  mkdir -p ${INSTALL}/usr/share/syslinux
    cp bios/mbr/mbr.bin ${INSTALL}/usr/share/syslinux
    cp bios/mbr/gptmbr.bin ${INSTALL}/usr/share/syslinux
    cp efi64/efi/syslinux.efi ${INSTALL}/usr/share/syslinux/bootx64.efi
    cp efi64/com32/elflink/ldlinux/ldlinux.e64  ${INSTALL}/usr/share/syslinux
}
