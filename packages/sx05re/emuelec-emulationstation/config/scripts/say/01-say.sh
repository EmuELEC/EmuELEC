#!/bin/bash

#file=$(mktemp)
#espeak -w ${file}.wav "${1}"
#aplay ${file}.wav
#rm ${file}.wav
killall aplay
killall espeak
espeak "${1}" --stdout | aplay
