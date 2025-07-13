#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

unset DEVICE_CFGLOAD
unset DEVICE_BOOT_LOGO
unset DEVICE_TIMEOUT_LOGO
unset DEVICE_DTB
unset DEVICE_UBOOT
unset DEVICE_CHAIN_UBOOT
unset DEVICE_BOOT_INI
unset DEVICE_BOOT_SCR
unset DEVICE_UBOOT_BIN
unset DEVICE_CHAIN_UBOOT_BIN

case ${1} in
  Khadas_VIM4)
    DEVICE_CFGLOAD="Generic_cfgload"  # used for generic image
    DEVICE_BOOT_LOGO="khadas_vim4-boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/t7_a311d2_khadas_vim4.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/build/u-boot.bin.sd.bin.signed"
  ;;
  Khadas_VIM1S)
    DEVICE_CFGLOAD="Generic_cfgload"  # used for generic image
    DEVICE_BOOT_LOGO="khadas_vim1s-boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/s4_s905y4_khadas_vim1s.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/build/u-boot.bin.sd.bin.signed"
  ;;
  Generic)
    DEVICE_CFGLOAD="${1}_cfgload"
  ;;
esac
