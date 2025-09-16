#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

clear > /dev/console
clear > /dev/tty1
clear > /dev/tty0
ee_console disable

set_video_controls
romdir="/storage/roms/"

PLAYER="${2}"

case ${PLAYER} in
	"ffplay")
MODE=`get_resolution`;
declare -a RES=( ${MODE} )
SIZE=" -x ${RES[0]} -y ${RES[1]}"

	player="ffplay -fs -autoexit -loglevel warning -hide_banner ${SIZE}"
	;;
	"vlc")
	# does not work...
	/usr/bin/vlc -I "dummy" --aout=alsa "${1}" vlc://quit < /dev/tty1 > /dev/null 2>&1
	;;
	"mpv")
	player="mpv -fs --volume-max=200 --really-quiet"
	;;
esac

cd /tmp

VIDEO_MODE=general
IS_YOUTUBE=$(cat "${1}" | grep -E "^https://www.youtube.com/.*")
[[ ! -z "${IS_YOUTUBE}" ]] && VIDEO_MODE=youtube
IS_TWITCH=$(cat "${1}" | grep -E "^https://www.twitch.tv/.*")
[[ ! -z "${IS_TWITCH}" ]] && VIDEO_MODE=twitch

[[ "${1}" == *".ytb" ]] && VIDEO_MODE=youtube
[[ "${1}" == *".twi" ]] && VIDEO_MODE=twitch

case ${VIDEO_MODE} in
	youtube)
		#Youtube Video
		${player} "/storage/.config/splash/youtube-1080.png"
		youtube-dl --quiet --no-warnings -o - -a "${1}" | ${player} - > /dev/tty1 2>&1
	;;
	twitch)
		# Twitch Video
		${player}  "/storage/.config/splash/twitch-1080.png" 
		youtube-dl --quiet --no-warnings -o - -a "${1}" | ${player} - > /dev/tty1 2>&1
	;;
	general)
	# Regular video
	${player} "${1}" #> /dev/tty1 2>&1
	;;
esac

clear > /dev/console
clear > /dev/tty1
clear > /dev/tty0

kill_video_controls
