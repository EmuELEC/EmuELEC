# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="crazycat"
PKG_REV="1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/crazycat69/media_build"
PKG_DEPENDS_TARGET="toolchain linux media_tree_cc"
PKG_NEED_UNPACK="${LINUX_DEPENDS} $(get_pkg_directory media_tree_cc)"
PKG_SECTION="driver.dvb"
PKG_LONGDESC="DVB driver for TBS cards with CrazyCats additions"

PKG_IS_ADDON="yes"
PKG_IS_KERNEL_PKG="yes"
PKG_ADDON_IS_STANDALONE="yes"
PKG_ADDON_NAME="DVB drivers for TBS"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_VERSION="${ADDON_VERSION}.${PKG_REV}"
PKG_ADDON_REQUIRES="script.program.driverselect:0.0.0"

case "${LINUX}" in
  amlogic-4.9)
    PKG_VERSION="ca1ea9fc2cfaedfc32bd0ac628e03e9aa379e3ad"
    PKG_SHA256="6b44a96d82c4a3e052864a995baceaede46b37c048c5718a6f62a009492d08ff"
    PKG_URL="https://github.com/crazycat69/media_build/archive/${PKG_VERSION}.tar.gz"
    PKG_DEPENDS_TARGET+=" media_tree_aml"
    PKG_NEED_UNPACK+=" $(get_pkg_directory media_tree_aml)"
    PKG_PATCH_DIRS="amlogic-4.9"
    ;;
  amlogic-5.4)
    PKG_VERSION="b8d777fd6c5a274f5f87cb7e67dae22e543d6554"
    PKG_SHA256="7a886032177fc7ca12abd120a14f81af5ff0ebffc225e8538d8cc332bb5cd765"
    PKG_URL="https://github.com/crazycat69/media_build/archive/${PKG_VERSION}.tar.gz"
    PKG_PATCH_DIRS="amlogic-5.4"
    ;;
esac

pre_make_target() {
  export KERNEL_VER=$(get_module_dir)
  export LDFLAGS=""
}

make_target() {
  cp -RP $(get_build_dir media_tree_cc)/* ${PKG_BUILD}/linux
  if [[ "${DEVICE}" = "Amlogic-ng"* ]]; then
    cp -Lr $(get_build_dir media_tree_aml)/* ${PKG_BUILD}/linux
    echo "obj-y += video_dev/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo "obj-y += dvb/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo 'source "drivers/media/platform/meson/dvb/Kconfig"' >>  "${PKG_BUILD}/linux/drivers/media/platform/Kconfig"
    sed -e 's/ && RC_CORE//g' -i ${PKG_BUILD}/linux/drivers/media/usb/dvb-usb/Kconfig
  fi

  # make config all
  kernel_make VER=${KERNEL_VER} SRCDIR=$(kernel_path) allyesconfig

  # add menuconfig to edit .config
  kernel_make VER=${KERNEL_VER} SRCDIR=$(kernel_path)
}

makeinstall_target() {
  install_driver_addon_files "${PKG_BUILD}/v4l/"
}
