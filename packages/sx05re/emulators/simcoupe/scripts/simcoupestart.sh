#!/bin/bash
. /etc/profile

ROM="${1}"

/usr/bin/simcoupe -rom /storage/roms/bios/samcoupe.rom -fullscreen -disk1 "${ROM}" -autoboot