# Rockchip

This project is for Rockchip SoC devices

## Devices

**RK3288**
* [ASUS Tinker Board](devices/RK3288)
* [mqmaker MiQi](devices/RK3288)

**RK3328**
* [Beelink A1 TV BOX](devices/RK3328)
* [PINE64 ROCK64](devices/RK3328)
* [Popcorn Hour Transformer](devices/RK3328)
* [Firefly ROC-RK3328-CC](devices/RK3328)

**RK3399**
* [96rocks ROCK960](devices/RK3399)
* [Hugsun X99 TV BOX](devices/RK3399)
* [Khadas Edge](devices/RK3399)
* [FriendlyARM NanoPC-T4](devices/RK3399)
* [FriendlyARM NanoPi M4](devices/RK3399)
* [Orange Pi RK3399](devices/RK3399)
* [PINE64 RockPro64](devices/RK3399)
* [Radxa ROCK Pi 4](devices/RK3399)
* [Radxa ROCK Pi 4+](devices/RK3399)
* [Radxa ROCK Pi N10](devices/RK3399)
* [ROC-RK3399-PC](devices/RK3399)
* [ROC-RK3399-PC-PLUS](devices/RK3399)
* [Rockchip Sapphire Board](devices/RK3399)

**My single-board computer is not listed, will it be added in the future?**<br>
If your single-board computer uses a current generation SoC listed on http://opensource.rock-chips.com/wiki_Main_Page the odds are in your favor.

**My Android device is not listed, will it be added in the future?**<br>
You may have luck if your device vendor is open source friendly, otherwise keep using Android for best support.

**My device does not boot and I don't understand why.**<br>
If your device has Android or any sort of vendor u-boot preinstalled in EMMC or SPI, make sure to add `ROCKCHIP_LEGACY_BOOT=1` when building an image.
This is done automatically for supported devices, which are known to come with Android preinstalled.

## Links

* http://opensource.rock-chips.com

## Useful debug commands

* `cat /sys/kernel/debug/dri/0/state`
* `cat /sys/kernel/debug/dri/0/framebuffer`
* `cat /sys/kernel/debug/dma_buf/bufinfo`
* `cat /sys/kernel/debug/cec/cec0/status`
* `hexdump -C /sys/class/drm/card0-HDMI-A-1/edid`
* `edid-decode /sys/class/drm/card0-HDMI-A-1/edid`
* `cat /sys/kernel/debug/clk/clk_summary`
* `cat /sys/kernel/debug/regulator/regulator_summary`
