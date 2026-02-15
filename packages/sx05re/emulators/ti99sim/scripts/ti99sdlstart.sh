#!/bin/bash
. /etc/profile

ROM="${1}"

/usr/bin/ti99sim-sdl --fullscreen --console=/storage/roms/bios/ti-994a.ctg "${ROM}"