#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

PLATFORM="${1}"

if [ "${2}" != "default" ]; then
    ROMNAME=$(basename "${2%.*}")
fi
RACONFIG="/storage/.config/retroarch/retroarch.cfg"
OPACITY="1.000000"
BEZELDIR="/storage/roms/bezels"
DEFAULT_BEZEL="false"
DEFAULT_SCALE="true"
DEFAULT_RATIO="22"

[ "${3}" != "true" ] && DEFAULT_SCALE="false"
[ ! -z "${4}" ] && DEFAULT_RATIO="${4}"

case ${PLATFORM} in
 "arcade"|"fbneo"|"fbn"|"neogeo"|"mame"|cps*)
   PLATFORM="ARCADE"
  ;;
  "none")
  if [ -f "/storage/.config/bezels_enabled" ]; then
  clear_bezel
  sed -i '/input_overlay = "/d' ${RACONFIG}
  sed -i '/input_overlay_enable = "/d' ${RACONFIG}
  rm "/storage/.config/bezels_enabled"
  fi
   exit 0
  ;;
  "SETUP")
  # fbterm does not need bezels
  exit 0
  ;;
esac

 if [ ! -f "/storage/.config/bezels_enabled" ]; then
   touch /storage/.config/bezels_enabled
 fi

# we make sure the platform is all lowercase
PLATFORM=${PLATFORM,,}

# bezelmap.cfg in ${BEZELDIR}/ is to share bezels between arcade clones and parent. 
BEZELMAP="/emuelec/configs/bezels/arcademap.cfg"
BZLNAME=$(sed -n "/"${PLATFORM}"_"${ROMNAME}" = /p" "${BEZELMAP}" 2>/dev/null)
BZLNAME="${BZLNAME#*\"}"
BZLNAME="${BZLNAME%\"*}"
OVERLAYDIR1=$(find ${BEZELDIR}/${PLATFORM} -maxdepth 1 -iname "${ROMNAME}*.cfg" | sort -V | head -n 1)
[ ! -z "${BZLNAME}" ] && OVERLAYDIR2=$(find ${BEZELDIR}/${PLATFORM} -maxdepth 1 -iname "${BZLNAME}*.cfg" | sort -V | head -n 1)
OVERLAYDIR3="${BEZELDIR}/${PLATFORM}/default.cfg"

OVERLAYDIR_ROM="/storage/roms/${PLATFORM}/images/${ROMNAME}-bezel.png"
OVERLAYDIR_ROM_CFG="/storage/roms/${PLATFORM}/images/${ROMNAME}-bezel.cfg"

clear_bezel() { 
		sed -i '/aspect_ratio_index = "/d' ${RACONFIG}
		sed -i '/custom_viewport_width = "/d' ${RACONFIG}
		sed -i '/custom_viewport_height = "/d' ${RACONFIG}
		sed -i '/custom_viewport_x = "/d' ${RACONFIG}
		sed -i '/custom_viewport_y = "/d' ${RACONFIG}
		sed -i '/video_scale_integer = "/d' ${RACONFIG}
		sed -i '/input_overlay_opacity = "/d' ${RACONFIG}
        sed -i '/input_overlay_enable = "/d' ${RACONFIG}
		echo "video_scale_integer = \"${DEFAULT_SCALE}\"" >> ${RACONFIG}
		echo "aspect_ratio_index = \"${DEFAULT_RATIO}\"" >> ${RACONFIG}
		echo 'input_overlay_opacity = "0.150000"' >> ${RACONFIG}
}

set_bezel() {
# ${OPACITY}: input_overlay_opacity
# ${1}: custom_viewport_width 
# ${2}: custom_viewport_height
# ${3}: ustom_viewport_x
# ${4}: custom_viewport_y
# ${5}: video_scale_integer
# ${6}: aspect_ratio_index
        clear_bezel
        sed -i '/input_overlay_opacity = "/d' ${RACONFIG}
        sed -i "1i input_overlay_opacity = \"${OPACITY}\"" ${RACONFIG}
		sed -i "2i aspect_ratio_index = \"${6}\"" ${RACONFIG}
		sed -i "3i custom_viewport_width = \"${1}\"" ${RACONFIG}
		sed -i "4i custom_viewport_height = \"${2}\"" ${RACONFIG}
		sed -i "5i custom_viewport_x = \"${3}\"" ${RACONFIG}
		sed -i "6i custom_viewport_y = \"${4}\"" ${RACONFIG}
		sed -i "7i video_scale_integer = \"${5}\"" ${RACONFIG}
        sed -i "8i input_overlay_enable = \"true\"" ${RACONFIG}
}

check_overlay_dir() {
# The bezel will be searched and used in following order:
# 1.${OVERLAYDIR1} will be used, if it does not exist, then
# 2.${OVERLAYDIR2} will be used, if it does not exist, then
# 3.${OVERLAYDIR2} platform default bezel as "${BEZELDIR}/"${PLATFORM}"/default.cfg\" will be used.
# 4.Default bezel at "${BEZELDIR}/default.cfg\" will be used.
	
	sed -i '/input_overlay = "/d' ${RACONFIG}
		
	if [ -f "${OVERLAYDIR_ROM}" ]; then
        if [ ! -f "${OVERLAYDIR_ROM_CFG}" ]; then
            echo "overlays = 1" > "${OVERLAYDIR_ROM_CFG}"
            echo "overlay0_full_screen = true" >> "${OVERLAYDIR_ROM_CFG}"
            echo "overlay0_descs = 0">> "${OVERLAYDIR_ROM_CFG}"
            echo "overlay0_overlay = \"${OVERLAYDIR_ROM}\"" >> "${OVERLAYDIR_ROM_CFG}"
        fi
        echo -e "input_overlay = \""${OVERLAYDIR_ROM_CFG}"\"\n" >> ${RACONFIG}
	elif [ -f "${OVERLAYDIR1}" ]; then
		echo -e "input_overlay = \""${OVERLAYDIR1}"\"\n" >> ${RACONFIG}
	elif [ -f "${OVERLAYDIR2}" ]; then
		echo -e "input_overlay = \""${OVERLAYDIR2}"\"\n" >> ${RACONFIG}
	elif [ -f "${OVERLAYDIR3}" ]; then
		echo -e "input_overlay = \""${OVERLAYDIR3}"\"\n" >> ${RACONFIG}
	else
		echo -e "input_overlay = \"${BEZELDIR}/default.cfg\"\n" >> ${RACONFIG}
		DEFAULT_BEZEL="true"
	fi
}

# Only 720P and 1080P can use bezels. For 480p/i and 576p/i we just delete bezel config.
hdmimode=$(get_resolution)

OGA_VER=$(oga_ver)

# This whole section needs to be reworked, specially for Odroid-GO Super, but for now we just force bezels at 720p
if [ "${OGA_VER}" == "OGS" ]; then
    hdmimode="OGS"
fi

case ${hdmimode} in
  *480)
	sed -i '/input_overlay = "/d' ${RACONFIG}
	clear_bezel
  ;;
  *576)
	sed -i '/input_overlay = "/d' ${RACONFIG}
	clear_bezel
  ;;
  "OGS"|*720)
	check_overlay_dir "${PLATFORM}"
        case "${PLATFORM}" in
            "gamegear")
                set_bezel "780" "580" "245" "70" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "gb")
                set_bezel "429" "380" "420" "155" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "gbc")
                set_bezel "430" "380" "425" "155" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "ngp")
                set_bezel "461" "428" "407" "145" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "ngpc")
                set_bezel "460" "428" "407" "145" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "wonderswan")
                set_bezel "645" "407" "325" "150" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            "wonderswancolor")
                set_bezel "643" "405" "325" "150" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
            ;;
            *)
                # delete aspect_ratio_index to make sure video is expanded fullscreen. Only certain handheld platforms need custom_viewport.
                clear_bezel
                sed -i '/input_overlay_opacity = "/d' ${RACONFIG}
                sed -i "1i input_overlay_opacity = \"${OPACITY}\"" ${RACONFIG}
            ;;
        esac
    ;;
    *)
        check_overlay_dir "${PLATFORM}"
        clear_bezel
        sed -i '/input_overlay_opacity = "/d' ${RACONFIG}
        sed -i "1i input_overlay_opacity = \"${OPACITY}\"" ${RACONFIG}
    ;;
esac

if [ "${DEFAULT_BEZEL}" = "true" ] && [ $(oga_ver) != "OGS" ]; then
	set_bezel "1427" "1070" "247" "10" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
elif [ "${OGA_VER}" != "OGS" ]; then
	set_bezel "1427" "1070" "247" "10" "${DEFAULT_SCALE}" "${DEFAULT_RATIO}"
fi
