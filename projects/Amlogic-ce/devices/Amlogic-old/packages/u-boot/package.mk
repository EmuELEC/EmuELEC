# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
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
[ ${PROJECT} = "Amlogic-ce" ] && PKG_CANUPDATE="${DEVICE}*"
PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader "

for PKG_SUBDEVICE in $SUBDEVICES; do
  PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
  PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE})"
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
    find_file_path bootloader/${PKG_SUBDEVICE}_boot.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    if [ $PKG_SUBDEVICE = "Odroid_C2" ]; then
      PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/u-boot.bin
    else
      PKG_UBOOTBIN=$(get_build_dir u-boot-${PKG_SUBDEVICE})/fip/u-boot.bin.sd.bin
    fi
    cp -av ${PKG_UBOOTBIN} $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_u-boot
    PKG_CANUPDATE+="|${PKG_SUBDEVICE}*"
  done
  find_file_path bootloader/config.ini && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@PROJECT@/${PKG_CANUPDATE}/g" \
        -i $INSTALL/usr/share/bootloader/canupdate.sh
  find_file_path splash/boot-logo.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
  find_file_path splash/boot-logo-1080.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
  find_file_path splash/timeout-logo-1080.bmp.gz && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
}
