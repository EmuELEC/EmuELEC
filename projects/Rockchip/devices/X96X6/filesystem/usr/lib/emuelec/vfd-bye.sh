#!/bin/sh
# VFD Shutdown Message — show BYE with fade out

. /usr/lib/emuelec/vfd-fd628.sh || exit 0

vfd_init

# Ensure ALL icons are OFF for BYE message
ICON_APPS=0; ICON_SETUP=0; ICON_USB=0; ICON_CARD=0
ICON_COLON=0; ICON_WIFI=0; ICON_DATA=0

vfd_brightness 7
vfd_text "BYE "
sleep 2

# Fade out over 0.7 seconds (7 steps × 0.1s)
for bright in 6 5 4 3 2 1 0; do
    vfd_brightness $bright
    sleep 0.1
done

vfd_clear
