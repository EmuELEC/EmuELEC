#!/bin/bash

fbdev=/dev/fb0 ;   width=1280 ; bpp=4
color="\x00\x00\x00\x00" #black colored

function pixel()
{  xx=${1} ; yy=${2}
   printf "${color}" | dd bs=${bpp} seek=$((${yy} * ${width} + ${xx})) \
                        of=${fbdev} &>/dev/null
}
x=0 ; y=0 ; clear
for i in {1..500}; do
   pixel $((x++)) $((y++))
done
