#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present KenshinX and Shanti Gilbert (https://github.com/emuelec)

source /usr/bin/env.sh
joy2keyStart

romdir="/storage/roms/"
[[ "${EE_DEVICE}" == "OdroidGoAdvance" ]] && TTY="/dev/tty1" || TTY="/dev/tty" 
[[ "${EE_DEVICE}" == "GameForce" ]] && TTY="/dev/tty1" || TTY="/dev/tty"

function buscarVideo {
local f=0
local f2=0
local t=0
local v=0
local ytstreams
local yttitles
local yttitles2
local ytthumbs

	#for t in $(seq 0 10 100) ; do sleep 1; echo ${t} | dialog --ascii-lines --backtitle "YouTube Video para EmuElec" --gauge "Generando resultados de la búsqueda..." 10 70 0; done
	mpv -fs "/storage/.config/splash/youtube-1080.png" --really-quiet
	
	ytresults=$(youtube-dl --restrict-filenames -j ytsearchdate10:"${ytSearchMode}")
	
	rm /tmp/ytresults
	echo ${ytresults} > /tmp/ytresults

	losid=$(grep -o '"webpage_url": *"[^"]*"' /tmp/ytresults | grep -o '"[^"]*"$' | sed 's/"//g')
	lostitulos=$(grep -o '"fulltitle": *"[^"]*"' /tmp/ytresults | grep -o '"[^"]*"$' | sed 's/"//g'| cut -c 1-50 | sed 's/|/-/g')
	duracionvideos=$(grep -o ', "duration": *[^,]*' /tmp/ytresults | grep -o '[^ ]*$')
	videopreview=$(grep -o '"thumbnail": *"[^"]*"' /tmp/ytresults | grep -o '"[^"]*"$' | sed 's/"//g' | sed 's/maxresdefault/hqdefault/g')

	for f in ${losid}; do
	ytstreams+=("${f}")
	done

	for v in ${videopreview}; do
	ytthumbs+=("${v}")
	done

	let i=0
	while read t; do
	yttitles+=("${t}")
	let i=${i}+1
	done <<< "${duracionvideos}"


	let i2=0
	while read f2; do
	yttitles2+=(${i2} "${f2} | $(date -d@${yttitles[i2]} -u +%H:%M:%S)")
	let i2=${i2}+1
	done <<< "${lostitulos}"

	playYTVideo
}

function playYTVideo {
clear
selectedstream=$(dialog --ascii-lines --backtitle "YouTube Video for EmuElec" --ok-label "Play" --column-separator "|" --title "${ytResultsLabel}"  --menu "Select a video to play" 0 0 0 "${yttitles2[@]}" 3>&2 2>&1 1>&3 > ${TTY})
return_value=$?

	case ${return_value} in
	0)
	clear
    mpv -fs "/storage/.config/splash/youtube-1080.png" --really-quiet
	    #mpv -fs "${ytthumbs[selectedstream]}"
	yt="${ytstreams[selectedstream]}"

	youtube-dl --quiet --no-warnings -o - ${yt} | mpv - -fs --quiet --really-quiet
#playYTVideo
	
	
	playYTVideo
	;;
	1)
	menuPrincipal
	;;
	esac
		
}

function listarPorYTBfile {
clear
	ytbfilelist=$(cat "/storage/roms/mplayer/youtube.ytb")
	ytSearchMode=${ytbfilelist}
	ytResultsLabel="Videos found on local youtube.ytb file:"
	buscarVideo

}
function listarPorInput {
clear
palabra=$(get_ee_setting youtube.searchword)
[[ -z "${palabra}" ]] && palabra="emuelec"

palabra=$(dialog --stdout --ascii-lines --backtitle "YouTube Video for EmuElec" --title "Search videos from Youtube" --inputbox "Type any term to search for videos" 0 0 "${palabra}" > ${TTY})
retval=$?

	case ${retval} in
	0)
	[[ -z "${palabra}" ]] && palabra="emuelec"
	#clear
	ytSearchMode="${palabra}"
	ytResultsLabel="Results for: '${palabra}'"
	buscarVideo
	;;
	1)
	menuPrincipal
	;;
	esac
}

function menuPrincipal {
clear
opcionmenu=$(dialog --ascii-lines --backtitle "YouTube Video for EmuElec" --title "Play videos from YouTube" --menu "Choose an option" 0 0 0 "1" "Search videos from YouTube" "2" "Play videos from local youtube.ytb file" 3>&2 2>&1 1>&3 > ${TTY})

	case ${opcionmenu} in
	1)
	listarPorInput
	;;
	2)
	listarPorYTBfile
	;;
	esac

}
menuPrincipal
