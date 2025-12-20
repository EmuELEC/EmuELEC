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
PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader "

for PKG_SUBDEVICE in $SUBDEVICES; do
  if [ "${PKG_SUBDEVICE}" != "Odroid_HC4" ]; then
    PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
    PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE})"
  fi
done

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
  sed -e "s/@KERNEL_NAME@/$KERNEL_NAME/g" \
      -e "s/@LEGACY_KERNEL_NAME@/$LEGACY_KERNEL_NAME/g" \
      -e "s/@LEGACY_DTB_NAME@/$LEGACY_DTB_NAME/g" \
      -i $INSTALL/usr/share/bootloader/update.sh

  # Always install the canupdate script
  if find_file_path bootloader/canupdate.sh; then
    cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
  fi

  for PKG_SUBDEVICE in $SUBDEVICES; do
    unset PKG_UBOOTBIN
    unset PKG_CHAINUBOOTBIN
    find_file_path bootloader/${PKG_SUBDEVICE}_boot.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    if [ "${PKG_SUBDEVICE:0:9}" = "Odroid_N2" -o "${PKG_SUBDEVICE}" = "Odroid_C4" -o "${PKG_SUBDEVICE}" = "Odroid_HC4" -o "${PKG_SUBDEVICE:0:10}" = "Radxa_Zero" ]; then
      if [ "${PKG_SUBDEVICE}" != "Odroid_HC4" ]; then
        PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/sd_fuse/u-boot.bin.sd.bin
      else
        PKG_UBOOTBIN=$(get_build_dir u-boot-Odroid_C4)/sd_fuse/u-boot.bin.sd.bin
      fi
    elif [ "${PKG_SUBDEVICE}" = "LePotato" ]; then
        PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/fip/u-boot.bin.sd.bin
        PKG_CHAINUBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/build/u-boot.bin
    elif [ "${PKG_SUBDEVICE}" = "LaFrite" ]; then
        PKG_CHAINUBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/build/u-boot.bin
    fi
    if [ ${PKG_UBOOTBIN} ]; then
        cp -av ${PKG_UBOOTBIN} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_u-boot
    fi
    if [ ${PKG_CHAINUBOOTBIN} ]; then
        cp -av ${PKG_CHAINUBOOTBIN} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_chain_u-boot
    fi
  done
  find_file_path bootloader/config.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@PROJECT@/${PKG_CANUPDATE}/g" \
        -i $INSTALL/usr/share/bootloader/canupdate.sh
  # Copy Hardkernel boot logo
  find_file_path splash/${DEVICE}/hk-boot-logo-1080.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
	# Copy Radxa boot logo
  find_file_path splash/${DEVICE}/radxa-boot-logo-1080.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
}
