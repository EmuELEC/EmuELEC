# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="dvb-latest"
PKG_LICENSE="GPL"
PKG_SITE="http://git.linuxtv.org/media_build.git"
PKG_URL="https://git.linuxtv.org/media_build.git"
GET_HANDLER_SUPPORT="git"
PKG_DEPENDS_TARGET="toolchain linux media_tree"
PKG_NEED_UNPACK="${LINUX_DEPENDS} $(get_pkg_directory media_tree)"
PKG_SECTION="driver.dvb"
PKG_LONGDESC="DVB drivers from the latest kernel (media_build)"

PKG_IS_ADDON="yes"
PKG_IS_KERNEL_PKG="yes"
PKG_ADDON_IS_STANDALONE="yes"
PKG_ADDON_NAME="DVB drivers from the latest kernel"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_VERSION="${ADDON_VERSION}.${PKG_REV}"
PKG_ADDON_REQUIRES="script.program.driverselect:0.0.0"

PKG_PATCH_DIRS="amlogic-common"
case "${LINUX}" in
  amlogic-4.9)
    PKG_VERSION="0f25e6fb13b6bc345218800ad9ac863deb2ee9c8"
    PKG_DEPENDS_TARGET+=" media_tree_aml"
    PKG_NEED_UNPACK+=" $(get_pkg_directory media_tree_aml)"
    PKG_PATCH_DIRS+=" amlogic-4.9"
    ;;
  amlogic-5.4)
    PKG_VERSION="680a07be51069bee47a07a4bcf36c5176f1290a4"
    PKG_PATCH_DIRS+=" amlogic-5.4"
    ;;
esac

pre_make_target() {
  export KERNEL_VER=$(get_module_dir)
  export LDFLAGS=""
}

make_target() {
  cp -RP $(get_build_dir media_tree)/* ${PKG_BUILD}/linux

  if [[ "${DEVICE}" = "Amlogic-ng"* ]]; then
    cp -Lr $(get_build_dir media_tree_aml)/* ${PKG_BUILD}/linux

    # compile modules
    echo "obj-y += video_dev/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo "obj-y += dvb/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo 'source "drivers/media/platform/meson/dvb/Kconfig"' >>  "${PKG_BUILD}/linux/drivers/media/platform/Kconfig"
    sed -e 's/ && RC_CORE//g' -i ${PKG_BUILD}/linux/drivers/media/usb/dvb-usb/Kconfig
  fi

  # make config all
  kernel_make VER=$KERNEL_VER SRCDIR=$(kernel_path) allyesconfig

  kernel_make VER=$KERNEL_VER SRCDIR=$(kernel_path)
}

makeinstall_target() {
  install_driver_addon_files "${PKG_BUILD}/v4l/"
}
