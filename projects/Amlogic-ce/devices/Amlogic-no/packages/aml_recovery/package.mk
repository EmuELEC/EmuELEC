# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

. $(get_pkg_directory linux)/package.mk

PKG_NAME="aml_recovery"
PKG_PATCH_DIRS+=" ${PROJECT_DIR}/${PROJECT}/packages/linux/patches"
PKG_PATCH_DIRS+=" ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/patches/linux"
PKG_URL=""
PKG_NEED_UNPACK="${LINUX_DEPENDS} $(get_pkg_directory initramfs) $(get_pkg_variable initramfs PKG_NEED_UNPACK)"
PKG_IS_KERNEL_PKG="no"
PKG_STAMP=""
PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} mkbootimg:host"
KERNEL_COMPILER="gcc"

if [ "${KERNEL_COMPILER}" = "clang" ]; then
  PKG_DEPENDS_TARGET+=" clang:host"
fi

# Ensure that the dependencies of initramfs:target are built correctly
for pkg in $(get_pkg_variable initramfs PKG_DEPENDS_TARGET); do
  ! listcontains "${PKG_DEPENDS_TARGET}" "${pkg}" && PKG_DEPENDS_TARGET+=" ${pkg}" || true
done

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/linux/linux-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}

  # copy kernel config file
  cp ${PKG_DIR}/config/linux.aarch64.conf ${PKG_BUILD}/.config
}

post_patch() {
  # set default hostname based on ${DISTRONAME}
  sed -i -e "s|@DISTRONAME@|${DISTRONAME}|g" ${PKG_BUILD}/.config

  # 5.4.125 kernel compile errors
  sed -e 's|^KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,).*||' \
      -e 's|^KBUILD_CFLAGS   := \(.*\)|KBUILD_CFLAGS   := -Wno-format -Wno-unused-function -Wno-misleading-indentation \1|' \
      -e 's|^KBUILD_LDFLAGS :=|KBUILD_LDFLAGS := $(call ld-option,--no-warn-rwx-segments)|' \
      -i ${PKG_BUILD}/Makefile
  sed -i 's|-z norelro||' ${PKG_BUILD}/arch/arm64/Makefile
}

build_gpio_data() {
  : # no need
}

make_target() {
  rm -rf ${BUILD}/initramfs
  rm -f ${STAMPS_INSTALL}/initramfs/install_target ${STAMPS_INSTALL}/*/install_init

  # create initramfs.cpio needed by Android boot image
  (
    cd ${ROOT}
    ${SCRIPTS}/install initramfs
  )

  kernel_make ${KERNEL_TARGET} ${KERNEL_MAKE_EXTRACMD}

  find_file_path bootloader/mkbootimg && source ${FOUND_PATH} initramfs
  mv -f arch/${TARGET_KERNEL_ARCH}/boot/boot.img arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  if [ -f arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET} ]; then
    cp arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET} ${INSTALL}/usr/share/bootloader/recovery.img
  fi
}
