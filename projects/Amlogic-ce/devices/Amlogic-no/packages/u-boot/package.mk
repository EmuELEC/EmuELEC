# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="u-boot"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain gcc-linaro-aarch64-elf:host gcc-linaro-arm-eabi:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_CANUPDATE="${PROJECT}*"
PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader"
[ -n "${DEVICE}" ] && PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

for PKG_SUBDEVICE in ${SUBDEVICES}; do
  PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
  PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE})"
  PKG_NEED_UNPACK+=" $(get_build_dir u-boot-${PKG_SUBDEVICE})/build/u-boot.bin"
done

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
  sed -e "s/@KERNEL_NAME@/${KERNEL_NAME}/g" \
      -e "s/@LEGACY_KERNEL_NAME@/${LEGACY_KERNEL_NAME}/g" \
      -e "s/@LEGACY_DTB_NAME@/${LEGACY_DTB_NAME}/g" \
      -i ${INSTALL}/usr/share/bootloader/update.sh

  # Always install the canupdate script
  if find_file_path bootloader/canupdate.sh; then
    cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
  fi

  # Always install the subdevice config script
  if find_file_path bootloader/subdevice_config.sh; then
    cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
  fi

  for PKG_SUBDEVICE in ${SUBDEVICES}; do
    . ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader/subdevice_config.sh ${PKG_SUBDEVICE} ${PKG_NAME}
    find_file_path bootloader/${DEVICE_BOOT_INI} && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    if [ ${DEVICE_UBOOT_BIN} ]; then
        cp -av ${DEVICE_UBOOT_BIN} ${INSTALL}/usr/share/bootloader/${DEVICE_UBOOT}
    fi
    if [ ${DEVICE_CHAIN_UBOOT_BIN} ]; then
        cp -av ${DEVICE_CHAIN_UBOOT_BIN} ${INSTALL}/usr/share/bootloader/${DEVICE_CHAIN_UBOOT}
    fi

    # Copy boot logo
    if [ ! -f ${INSTALL}/usr/share/bootloader/${DEVICE_BOOT_LOGO} ]; then
      find_file_path splash/${DEVICE}/${DEVICE_BOOT_LOGO} && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    fi
    if [ ! -f ${INSTALL}/usr/share/bootloader/${DEVICE_TIMEOUT_LOGO} ]; then
      find_file_path splash/${DEVICE}/${DEVICE_TIMEOUT_LOGO} && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    fi
  done
  find_file_path bootloader/config.ini && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    sed -e "s/@PROJECT@/${PKG_CANUPDATE}/g" \
        -i ${INSTALL}/usr/share/bootloader/canupdate.sh
}
