# RK3328

This is a SoC device for RK3328

**Build**

* `PROJECT=Rockchip DEVICE=RK3328 ARCH=arm UBOOT_SYSTEM=a1 make image`
* `PROJECT=Rockchip DEVICE=RK3328 ARCH=arm UBOOT_SYSTEM=roc-cc make image`
* `PROJECT=Rockchip DEVICE=RK3328 ARCH=arm UBOOT_SYSTEM=rock64 make image`

**How to use on an Android device**
- Flash image to a sd-card
- Insert sd-card into the device
- Plug in power and LibreELEC should boot instead of Android
- Remove sd-card from device to boot into Android
