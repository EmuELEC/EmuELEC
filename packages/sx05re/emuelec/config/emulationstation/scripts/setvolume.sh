#!/bin/bash

# Argument ${1} is the program name ${2} is the volume value (without "%")

CURRENTVOL=$(pactl list sink-inputs | grep ${1} -B 20 | grep "front-left:" | cut -d "/" -f 2)
pactl set-sink-input-volume $(pactl list sink-inputs | grep ${1} -B 20 | grep "#" | cut -d \# -f 2) "${2}"%
