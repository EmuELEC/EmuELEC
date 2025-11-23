# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtkbt-firmware-aml"
PKG_VERSION="77ec2c6cbccc8fa76bf1026726a13dd15e79d536"
PKG_SHA256="5025ff8a7e2ace6ea6734d6d0d3855aeb0c112704ab09555125fd5b850980c6d"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/rtkbt-firmware-aml"
PKG_URL="https://github.com/CoreELEC/rtkbt-firmware-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain rtk_hciattach"
PKG_LONGDESC="Realtek BT Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  FWDIR=${INSTALL}/$(get_full_firmware_dir)/rtlbt

  mkdir -p ${FWDIR}
    cp -a ${PKG_BUILD}/* ${FWDIR}
}
