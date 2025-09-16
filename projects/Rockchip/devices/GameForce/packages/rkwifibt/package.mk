# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="rkwifibt"
PKG_VERSION="a389710ca130405a0e6e4f22bc0335c976a5c4b0"
PKG_SITE="https://github.com/shantigilbert/rkwifibt"
PKG_URL="$PKG_SITE.git"
PKG_LICENSE="Unspecified"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="rkwifibt"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

BT_TTY_DEV="ttyS1"
RKWIFIBT_TOOLCHAIN=${TOOLCHAIN}
RKARCH="arm64"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
    ${CC} -o ${PKG_BUILD}/brcm_tools/brcm_patchram_plus1 ${PKG_BUILD}/brcm_tools/brcm_patchram_plus1.c
    ${CC} -o ${PKG_BUILD}/brcm_tools/dhd_priv ${PKG_BUILD}/brcm_tools/dhd_priv.c
    ${CC} -o ${PKG_BUILD}/src/rk_wifi_init ${PKG_BUILD}/src/rk_wifi_init.c
    make -C ${PKG_BUILD}/realtek/rtk_hciattach/ CC=${CC}
	make -C $(kernel_path) M=${PKG_BUILD}/realtek/bluetooth_uart_driver ARCH=$TARGET_KERNEL_ARCH CROSS_COMPILE=$TARGET_KERNEL_PREFIX
}

makeinstall_target() {
	mkdir -p $INSTALL/etc
    cp -rf ${PKG_BUILD}/wpa_supplicant.conf ${INSTALL}/etc/
    cp -rf ${PKG_BUILD}/dnsmasq.conf ${INSTALL}/etc/

	mkdir -p $INSTALL/usr/bin
    cp -rf ${PKG_BUILD}/wifi_start.sh ${INSTALL}/usr/bin/
    cp -rf ${PKG_BUILD}/src/rk_wifi_init ${INSTALL}/usr/bin/
    cp -rf ${PKG_BUILD}/realtek/rtk_hciattach/rtk_hciattach ${INSTALL}/usr/bin/

	mkdir -p $INSTALL/$(get_full_firmware_dir)/RTL8723DS
	cp ${PKG_BUILD}/realtek/RTL8723DS/* $INSTALL/$(get_full_firmware_dir)/RTL8723DS/

	mkdir -p $INSTALL/$(get_full_module_dir)/RTL8723DS
	cp ${PKG_BUILD}/realtek/bluetooth_uart_driver/hci_uart.ko $INSTALL/$(get_full_module_dir)/RTL8723DS/
#   $(kernel_path)/build.sh modules
	
	#kernel_make -C $(kernel_path) M=${PKG_BUILD}/realtek/bluetooth_uart_driver ARCH=$TARGET_KERNEL_ARCH CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    #INSTALL_MOD_PATH=$INSTALL/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
    #modules_install
    
    #find $(kernel_path)/drivers/net/wireless/rockchip_wlan/* -name *8723ds*.ko | xargs -n1 -i cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME
    #usr/lib/kernel-overlays/base/lib/modules/4.4.189/kernel/drivers/net/wireless/rockchip_wlan/rtl8723ds
    #cp *.ko $INSTALL/$(get_full_module_dir)/$PKG_NAME
}

