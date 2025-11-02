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
  Odroid_C4)
    DEVICE_BOOT_LOGO="odroid_boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/sm1_s905x3_odroid_c4.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
  Odroid_N2)
    DEVICE_BOOT_LOGO="odroid_boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/g12b_s922x_odroid_n2.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
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
  Radxa_Zero)
    DEVICE_BOOT_LOGO="radxa-boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/g12a_s905y2_radxa_zero.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
  Radxa_Zero2)
    DEVICE_BOOT_LOGO="radxa-boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/g12b_a311d_radxa_zero2.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
  Alta)
    DEVICE_BOOT_LOGO="libre-computer_boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/g12b_a311d_libre_computer_alta.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
  Solitude)
    DEVICE_BOOT_LOGO="libre-computer_boot-logo.bmp.gz"
    DEVICE_DTB="device_trees/sm1_s905d3_libre_computer_solitude.dtb"
    DEVICE_UBOOT="${1}_u-boot"
    DEVICE_BOOT_INI="${1}_boot.ini"
    [ -n "${2}" ] && DEVICE_UBOOT_BIN="$(get_build_dir u-boot-${1})/sd_fuse/u-boot.bin.sd.bin"
  ;;
  Generic)
    DEVICE_CFGLOAD="${1}_cfgload"
  ;;
esac
