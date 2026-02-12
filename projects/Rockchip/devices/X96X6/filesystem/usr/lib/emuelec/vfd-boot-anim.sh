#!/bin/sh
# Loading animation for X96X6 VFD — circular segment sweep
# Pure animation loop — started/stopped by vfd-clock-daemon.sh
# Used for: boot loading, ES restart, game loading

. /usr/lib/emuelec/vfd-fd628.sh

while true; do
    vfd_display_segments 240 240 0 0 0 0 0
    usleep 150000 2>/dev/null || sleep 0.15

    vfd_display_segments 0 240 240 0 0 0 0
    usleep 150000 2>/dev/null || sleep 0.15

    vfd_display_segments 0 0 240 240 0 0 0
    usleep 150000 2>/dev/null || sleep 0.15

    vfd_display_segments 0 0 0 240 240 0 0
    usleep 150000 2>/dev/null || sleep 0.15

    vfd_display_segments 0 0 0 0 240 240 0
    usleep 150000 2>/dev/null || sleep 0.15

    vfd_display_segments 240 0 0 0 0 240 0
    usleep 150000 2>/dev/null || sleep 0.15
done
