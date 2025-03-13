#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

SMP="../smp_affinity"
MESONIR="`find /proc/irq/ -name *meson*ir`"
ETH0="`find /proc/irq/ -name eth0`"
VDEC0="`find /proc/irq/ -name vdec-0`"
VDEC1="`find /proc/irq/ -name vdec-1`"
PREDI="`find /proc/irq/ -name pre_di`"
AFIFO0="`find /proc/irq/ -name afifo0`"
AOCEC="`find /proc/irq/ -name hdmi_aocec*`"
USB3="`find /proc/irq/ -name xhci-hcd:usb1`"
IRQ="$AOCEC $ETH0 $USB3 $VDEC0 $VDEC1 $AFIFO0 $MESONIR $PREDI"

cpu=1
for i in $IRQ; do
    if [ -f "$i/$SMP" ];then
        [ ! -d "/sys/devices/system/cpu/cpu$cpu" ] && cpu=1
        aff=$((1 << $cpu))
        haff=`printf '%x\n' $aff`
        echo "echo $haff > $i/$SMP"
        echo $haff > $i/$SMP
        cpu=$((cpu + 1))
    fi
done

exit 0
