## Install Instructions

The Dragonboard is unique in the way that it uses and android bootloader to load the OS. This makes it difficult for a few reasons:

1) Requires a very specific partition layout
2) Typically requires a secondary bootloader (usually little kernel (LK). we use u-boot).

All this makes it difficult to create a disk image that can easily be flashed and booted natively. After some time trying various different configurations this is what I landed on:

#### Flash the .img file to and SD card (dd, rufus, LE disk image tool, etc)
```
gunzip LibreELEC-Dragonboard.arm-9.80-devel-20190706164625-ce7dc9b-410c.img.gz
dd if=LibreELEC-Dragonboard.arm-9.80-devel-20190706164625-ce7dc9b-410c.img of=/dev/sdx bs=4M
```

 #### Mount the first partition
 ```
 mount /dev/sdx1 /mnt (or similar)
```

#### Mount the squashfs SYSTEM file
```
 mount -o loop /mnt/SYSTEM /mnt2 (or similar)
 ```
#### Write the u-boot bootloader using fastboot

to write u-boot to the boot partition on the emmc you will need to use fastboot. (NOTE: this will wipe out whatever you have in the boot partition on the emmc and will make it so that OS does not boot anymore).

To enter fastboot mode read the following instructions:

1) While holding the Vol (-) button, power on the DragonBoard™ 410c by plugging it in
2) Once DragonBoard™ 410c is plugged into power, release your hold on the Vol (-) button.
3) Wait for about 20 seconds.
4) Board should boot into fastboot mode.
```
fastboot flash boot /mnt2/usr/share/bootloader/u-boot.img
```

#### Unmount partitions
```
umount /mnt2
umount /mnt
```

#### Plug SD card into Dragonboard and power on
