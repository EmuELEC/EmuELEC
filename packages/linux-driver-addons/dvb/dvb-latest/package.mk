# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dvb-latest"
PKG_VERSION="10.0-latest"
PKG_SHA256="50ed45ec6eeac0c8d537f8de3e7e82ef1f37b2f91552cdd99fbda05e5646f351"
PKG_LICENSE="GPL"
PKG_SITE="http://git.linuxtv.org/media_build.git"
PKG_URL="https://github.com/LibreELEC/media_build/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_UNPACK="media_tree"
PKG_SECTION="driver.dvb"
PKG_LONGDESC="DVB drivers from the latest kernel (media_build)"

PKG_IS_ADDON="embedded"
PKG_IS_KERNEL_PKG="yes"
PKG_ADDON_IS_STANDALONE="yes"
PKG_ADDON_NAME="DVB drivers from the latest kernel"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_VERSION="${ADDON_VERSION}.${PKG_REV}"

if [ "${PROJECT}" = "Amlogic-ce" ]; then
  PKG_PATCH_DIRS="amlogic-common"
  case "${LINUX}" in
    amlogic-3.14)
      PKG_PATCH_DIRS+=" amlogic-3.14"
      ;;
    amlogic-4.9)
      PKG_PATCH_DIRS+=" amlogic-4.9"
      ;;
  esac
  PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} media_tree_aml"
  PKG_NEED_UNPACK="${PKG_NEED_UNPACK} $(get_pkg_directory media_tree_aml)"
fi

pre_make_target() {
  export KERNEL_VER=$(get_module_dir)
  export LDFLAGS=""
}

make_target() {
  cp -RP $(get_build_dir media_tree)/* ${PKG_BUILD}/linux

  if [ "${PROJECT}" = "Amlogic-ce" ]; then
    cp -Lr $(get_build_dir media_tree_aml)/* ${PKG_BUILD}/linux

    # compile modules
    echo "obj-y += video_dev/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo "obj-y += dvb/" >> "${PKG_BUILD}/linux/drivers/media/platform/meson/Makefile"
    echo 'source "drivers/media/platform/meson/dvb/Kconfig"' >>  "${PKG_BUILD}/linux/drivers/media/platform/Kconfig"
    sed -e 's/ && RC_CORE//g' -i ${PKG_BUILD}/linux/drivers/media/usb/dvb-usb/Kconfig
  fi

  # make config all
  kernel_make VER=${KERNEL_VER} SRCDIR=$(kernel_path) allyesconfig

  kernel_make VER=${KERNEL_VER} SRCDIR=$(kernel_path)
}

makeinstall_target() {
  install_driver_addon_files "${PKG_BUILD}/v4l/"
}
