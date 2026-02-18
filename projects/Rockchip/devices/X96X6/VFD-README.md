# X96X6 VFD Display Setup

## Overview

Native GPIO-based VFD control for FD628 chip on X96X6, bypassing openvfd driver (not compatible with RK3566).

## Architecture

Non-blocking FIFO-based architecture. All display operations go through a named pipe,
ensuring no process ever blocks waiting for GPIO access.

```
  vfd-clock-updater.sh ──┐
  vfd-state-monitor.sh ──┼──> /tmp/vfd.fifo ──> vfd-service.sh ──> GPIO ──> FD628
  vfd-send (CLI) ────────┘
```

### Files

| File | Purpose |
|------|---------|
| `/usr/lib/emuelec/vfd-fd628.sh` | FD628 GPIO control library (SPI bit-bang) |
| `/usr/lib/emuelec/vfd-service.sh` | Main service — reads FIFO, owns GPIO exclusively |
| `/usr/lib/emuelec/vfd-clock-updater.sh` | Independent clock — sends time at minute boundaries |
| `/usr/lib/emuelec/vfd-state-monitor.sh` | ES/game state watcher + icon auto-detection |
| `/usr/lib/emuelec/vfd-boot-anim.sh` | Loading animation loop (circular segment sweep) |
| `/usr/lib/emuelec/vfd-bye.sh` | Shutdown display (BYE + fade out) |
| `/usr/lib/emuelec/vfd-timezone-setup.sh` | One-time timezone auto-detection via IP |
| `/usr/bin/vfd-send` | CLI command sender (non-blocking FIFO write) |
| `/usr/lib/systemd/system/vfd-x96x6.service` | systemd service |

## Manual Setup (one-time)

After flashing the image, run on device:

```bash
systemctl enable vfd-x96x6.service
systemctl start vfd-x96x6.service
```

## Icon Mapping (5th position, grid 4)

| Icon | Segment | Bit |
|------|---------|-----|
| apps | A (byte0) | bit3 |
| setup | B (byte2) | bit3 |
| usb | C (byte4) | bit3 |
| card | D (byte6) | bit3 |
| colon | E (byte8) | bit3 |
| wifi | F (byte10) | bit3 |
| data | G (byte12) | bit3 |

## Usage Examples

### Send commands via FIFO:

```bash
vfd-send clock 12 30        # Show time 12:30
vfd-send text GAME           # Show 4-character text
vfd-send icon wifi on        # Set icon
vfd-send icon usb off        # Clear icon
vfd-send anim start          # Start loading animation
vfd-send anim stop           # Stop animation, show clock
vfd-send brightness 5        # Set brightness (0-7)
vfd-send clear               # Clear display
vfd-send bye                 # Shutdown sequence
```

### Direct library usage (for testing):

```bash
. /usr/lib/emuelec/vfd-fd628.sh
vfd_init
vfd_text "ELEC"
vfd_clock 12 30
```

## Auto-enable at build time

Add to `projects/Rockchip/devices/X96X6/post-install.sh`:

```bash
ln -sf /usr/lib/systemd/system/vfd-x96x6.service \
       $INSTALL/usr/lib/systemd/system/multi-user.target.wants/vfd-x96x6.service
```
