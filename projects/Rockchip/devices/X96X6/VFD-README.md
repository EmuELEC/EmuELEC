# X96X6 VFD Display Setup

## Overview

Native GPIO-based VFD control for FD628 chip on X96X6, bypassing openvfd driver (not compatible with RK3566).

## Files Created

- `/usr/lib/emuelec/vfd-fd628.sh` - FD628 control library
- `/usr/lib/emuelec/vfd-clock` - Clock display daemon
- `/usr/lib/systemd/system/vfd-x96x6.service` - Systemd service
- `/usr/bin/vfd-icon` - Icon control utility

## Manual Setup (one-time)

After flashing the image, run on device:

```bash
systemctl enable vfd-x96x6.service
systemctl start vfd-x96x6.service
```

## Icon Mapping (5th position, grid 4)

- `apps` = segment a (0x01)
- `setup` = segment b (0x02)
- `usb` = segment c (0x04)
- `card` = segment d (0x08)
- `colon` = segment e (0x10)
- `wifi` = segment f (0x20)
- `data` = segment g (0x40)

## Usage Examples

### Display text:

```bash
. /usr/lib/emuelec/vfd-fd628.sh
vfd_setup
vfd_text "ELEC" 0
```

### Control icons:

```bash
vfd-icon wifi on
vfd-icon setup on
vfd-icon usb off
```

### Show clock:

```bash
vfd_clock
```

## Auto-enable at build time

Add to `projects/Rockchip/devices/X96X6/post-install.sh`:

```bash
ln -sf /usr/lib/systemd/system/vfd-x96x6.service \
       $INSTALL/usr/lib/systemd/system/multi-user.target.wants/vfd-x96x6.service
```
