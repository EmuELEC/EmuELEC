#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# This whole file has become very hacky, I am sure there is a better way to do all of this, but for now, this works.

blank_buffer

if [ -f "/usr/bin/odroidgoa_utils.sh" ]; then
    DEFBRIGHT=$(get_ee_setting brightness.level)
    RACONF=/storage/.config/retroarch/retroarch.cfg
    sed -i "/screen_brightness/d" ${RACONF}
    echo "screen_brightness = \"${DEFBRIGHT}\"" >> ${RACONF}
fi

BTENABLED=$(get_ee_setting ee_bluetooth.enabled)

if [[ "${BTENABLED}" == "1" ]]; then
        # We don't need the BT agent while running games
    systemctl stop bluetooth-agent
fi

# clear terminal window
        clear > /dev/tty < /dev/null 2>&1
        clear > /dev/tty0 < /dev/null 2>&1
        clear > /dev/tty1 < /dev/null 2>&1
        clear > /dev/console < /dev/null 2>&1

arguments="$@"

emuelec-utils setauddev

# set audio to alsa
set_audio alsa

# Set the variables
CFG="/storage/.emulationstation/es_settings.cfg"
LOGEMU="No"
VERBOSE=""
LOGSDIR="/emuelec/logs"
TBASH="/usr/bin/bash"
RACONF="/storage/.config/retroarch/retroarch.cfg"
NETPLAY="No"
RABIN="retroarch"

init_game

# Make sure the /emuelec/logs directory exists
if [[ ! -d "${LOGSDIR}" ]]; then
    mkdir -p "${LOGSDIR}"
fi

USELOG="1"
LOGLEVEL=$(get_ee_setting "retroarchLogging" "global")
if [[ ${arguments} == *"--NOLOG"* ]] || [[ "${LOGLEVEL}" == "0" ]]; then
  USELOG="0"
fi

if [ "${USELOG}" == "0" ]; then
    EMUELECLOG="/dev/null"
    cat /etc/motd > "${LOGSDIR}/emuelec.log"
    echo "Logging has been disabled, enable it in Main Menu > System Settings > Developer > Log Level" >> "${LOGSDIR}/emuelec.log"
else
    EMUELECLOG="${LOGSDIR}/emuelec.log"
fi

set_kill_keys() {
    # If gptokeyb is running we kill it first.
    kill_video_controls
    KILLTHIS=${1}
    KILLSIGNAL=${2}
}

# Extract the platform name from the arguments
PLATFORM="${arguments##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found

CORE="${arguments##*--core=}"  # read from --core= onwards
CORE="${CORE%% *}"  # until a space is found

EMULATOR="${arguments##*--emulator=}"  # read from --emulator= onwards
EMULATOR="${EMULATOR%% *}"  # until a space is found

ROMNAME="${1}"
BASEROMNAME=${ROMNAME##*/}
GAMEFOLDER="${ROMNAME//${BASEROMNAME}}"

KILLTHIS="none"
KILLSIGNAL="15"

if [[ "${CORE}" == *"_32b"* ]]; then
    BIT32="yes"
    #LD_LIBRARY_PATH="/emuelec/lib32:${LD_LIBRARY_PATH}"
    RABIN="retroarch32"
else
    BIT32="No"
fi

if [[ "${EMULATOR}" = "libretro" ]]; then
    [[ -f "/storage/.config/RA_KILL_KEYS" ]] && set_kill_keys "${RABIN}"
    EMU="${CORE}_libretro"
    LIBRETRO="yes"
    RETRORUN=""
else
        EMU="${CORE}"
fi

if [[ "${EMULATOR}" = "retrorun" ]]; then
                RR_EXE="retrorun"
                [[ "${BIT32}" == "yes" ]] && RR_EXE="retrorun32"
                set_kill_keys "${RR_EXE}"
    EMU="${CORE}_libretro"
    RETRORUN="yes"
    LIBRETRO=""
fi

ROTATION_OUTPUT=$(get_ee_setting "${EMULATOR}.rotation_output" "${PLATFORM}" "${BASEROMNAME}")
[[ -z "${ROTATION_OUTPUT}" ]] && ROTATION_OUTPUT=0
CMD_ROTATE=$(emuelec-utils set_rotation "${ROTATION_OUTPUT}" "${EMULATOR}")

MIDI_OUTPUT=$(get_ee_setting "ra_midi_output" "${PLATFORM}" "${BASEROMNAME}")
if [[ ! -z "${MIDI_OUTPUT}" ]]; then
		emuelec-utils set_midi_source "${MIDI_OUTPUT}" "${EMULATOR}"
fi

# freej2me needs the JDK to be downloaded on the first run
if [ ${EMU} == "freej2me_libretro" ]; then
freej2me.sh

JAVA_HOME='/storage/roms/bios/jdk'
export JAVA_HOME
PATH="${JAVA_HOME}/bin:${PATH}"
export PATH

fi

# Ports that use this file are all Libretro, so lets set it
[[ ${PLATFORM} = "ports" ]] && LIBRETRO="yes"

# if there wasn't a --NOLOG included in the arguments, enable the emulator log output. TODO: this should be handled in ES menu
if [ "${USELOG}" == "1" ]; then
    LOGEMU="Yes"
    VERBOSE="-v"
fi

# Get the latest save files if there is any
CLOUD_SYNC=$(get_ee_setting "${PLATFORM}.cloudsave")
[[ "${CLOUD_SYNC}" == "1" ]] && ra_rclone.sh get "${PLATFORM}" "${ROMNAME}" &
CLOUD_PID=$!

emuelec-utils init_app_video "${PLATFORM}" "${ROMNAME}"

CONTROLLERCONFIG="${arguments#*--controllers=*}"
echo "${CONTROLLERCONFIG}" | tr -d '"' > "/tmp/controllerconfig.txt"

if [ -z ${LIBRETRO} ] && [ -z ${RETRORUN} ]; then

GPTOKEYB=$(get_ee_setting "gptokeyb" "${PLATFORM}" "${BASEROMNAME}")
VIRTUAL_KB=

# Read the first argument in order to set the right emulator
case ${PLATFORM} in
        "atari2600")
                if [ "${EMU}" = "STELLASA" ]; then
            set_kill_keys "stella"
            RUNTHIS='${TBASH} stella.sh "${ROMNAME}"'
                fi
                ;;
        "atarist")
                if [ "${EMU}" = "HATARISA" ]; then
            set_kill_keys "hatari"
            RUNTHIS='${TBASH} hatari.start "${ROMNAME}"'
                fi
                ;;
        "openbor")
                VIRTUAL_KB=$(emuelec-utils set_gptokeyb "${PLATFORM}" "${GPTOKEYB}")
                set_kill_keys "${EMU}"
                RUNTHIS='${TBASH} openbor.sh "${ROMNAME}" "${EMU}"'
                ;;
        "setup")
        if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
            set_kill_keys "kmscon"
        else
            set_kill_keys "fbterm"
        fi
                RUNTHIS='${TBASH} fbterm.sh "${ROMNAME}"'
                EMUELECLOG="${LOGSDIR}/ee_script.log"
                ;;
        "dreamcast"|"naomi"|"atomiswave")
                if [ "${EMU}" = "flycastsa" ]; then
            set_kill_keys "flycast"
            RUNTHIS='${TBASH} flycast.sh "${ROMNAME}"'
        fi
                ;;
        "psx")
                if [ "${EMU}" = "duckstation" ]; then
            set_kill_keys "duckstation-nogui"
            RUNTHIS='${TBASH} duckstation.sh "${ROMNAME}"'
        fi
                ;;
        "mame"|"arcade"|"cps1"|"cps2"|"cps3")
                if [ "${EMU}" = "AdvanceMame" ]; then
            set_kill_keys "advmame" 3
            RUNTHIS='${TBASH} advmame.sh "${PLATFORM}" "${ROMNAME}"'
                elif [ "${EMU}" = "FbneoSA" ]; then
            set_kill_keys "fbneo"
            RUNTHIS='fbneo.sh "${ROMNAME}"'
                fi
                ;;
        "fbn"|"neogeo")
        if [ "${EMU}" = "FbneoSA" ]; then
            set_kill_keys "fbneo"
            RUNTHIS='fbneo.sh "${ROMNAME}"'
                fi
                ;;
        "nds")
                set_kill_keys "drastic"
                RUNTHIS='${TBASH} /storage/.emulationstation/scripts/drastic.sh "${ROMNAME}"'
                ;;
        "n64")
                if [ "${EMU}" = "rice" ]; then
            set_kill_keys "mupen64plus"
            RUNTHIS='${TBASH} m64p.sh "${ROMNAME}"'
                elif [ "${EMU}" = "glide64mk2" ]; then
            set_kill_keys "mupen64plus"
            RUNTHIS='${TBASH} m64p.sh "${ROMNAME}" m64p_gl64mk2'
        fi
                ;;
        "amiga"|"amigacd32")
                if [ "${EMU}" = "AMIBERRY" ]; then
            RUNTHIS='${TBASH} amiberry.start "${ROMNAME}"'
                fi
                ;;
        "scummvm")
                if [[ "${ROMNAME}" == *".sh" ]]; then
            set_kill_keys "fbterm"
            RUNTHIS='${TBASH} fbterm.sh "${ROMNAME}"'
            EMUELECLOG="${LOGSDIR}/ee_script.log"
                else
                if [ "${EMU}" = "SCUMMVMSA" ]; then
            set_kill_keys "scummvm"
            RUNTHIS='${TBASH} scummvm.start sa "${ROMNAME}"'
                else
            RUNTHIS='${TBASH} scummvm.start libretro'
                fi
                fi
                ;;
        "solarus")
                set_kill_keys "solarus-run"
                RUNTHIS='${TBASH} solarus.sh "${ROMNAME}"'
                        ;;
        "daphne")
                if [ "${EMU}" = "HYPSEUS" ]; then
            set_kill_keys "hypseus"
            RUNTHIS='${TBASH} hypseus.start.sh "${ROMNAME}"'
                fi
                ;;
        "wii"|"gamecube")
                if [ "${EMU}" = "dolphin" ]; then
            set_kill_keys "dolphin-emu-nogui"
            RUNTHIS='${TBASH} dolphin.sh "${ROMNAME}"'
                fi
                ;;
        "pc")
                if [ "${EMU}" = "DOSBOXSDL2" ]; then
            set_kill_keys "dosbox"
            RUNTHIS='${TBASH} dosbox.start "${ROMNAME}"'
            #RUNTHIS='${TBASH} dosbox.start -conf "${GAMEFOLDER}dosbox-SDL2.conf"'
                fi
                if [ "${EMU}" = "DOSBOX-X" ]; then
            set_kill_keys "dosbox-x"
            RUNTHIS='${TBASH} dosbox-x.start "${ROMNAME}"'
            #RUNTHIS='${TBASH} dosbox-x.start -conf "${GAMEFOLDER}dosbox-SDL2.conf"'
                fi
                ;;
        "psp"|"pspminis")
                if [ "${EMU}" = "PPSSPPSDL" ]; then
            set_kill_keys "PPSSPPSDL"
            RUNTHIS='${TBASH} ppsspp.sh "${ROMNAME}"'
                fi
                ;;
        "neocd")
                if [ "${EMU}" = "fbneo" ]; then
            RUNTHIS='${RABIN} ${VERBOSE} -L /tmp/cores/fbneo_libretro.so --subsystem neocd --config ${RACONF} "${ROMNAME}"'
                elif [ "${EMU}" = "FbneoSA" ]; then
            set_kill_keys "fbneo"
            RUNTHIS='fbneo.sh "${ROMNAME}" NCD'
                fi
                ;;
        "mplayer")
                set_kill_keys "${EMU}"
                RUNTHIS='${TBASH} fbterm.sh mplayer_video "${ROMNAME}" "${EMU}"'
                ;;
        "pico8")
                set_kill_keys "pico8_dyn"
                RUNTHIS='${TBASH} pico8.sh "${ROMNAME}"'
                        ;;
        "prboom")
        if [ "${EMU}" = "Chocolate-Doom" ]; then
            set_kill_keys "chocolate-doom"
            CONTROLLERCONFIG="${arguments#*--controllers=*}"
            RUNTHIS='${TBASH} chocodoom.sh "${ROMNAME}" --controllers="${CONTROLLERCONFIG}"'
        elif [ "${EMU}" = "LZDoom" ]; then
            set_kill_keys "lzdoom"
            CONTROLLERCONFIG="${arguments#*--controllers=*}"
            RUNTHIS='${TBASH} lzdoom.sh "${ROMNAME}" --controllers="${CONTROLLERCONFIG}"'
        elif [ "${EMU}" = "GZDoom" ]; then
            set_kill_keys "gzdoom"
            CONTROLLERCONFIG="${arguments#*--controllers=*}"
            RUNTHIS='${TBASH} gzdoom.sh "${ROMNAME}" --controllers="${CONTROLLERCONFIG}"'
        fi
        ;;
        "ecwolf")
        if [ "${EMU}" = "ecwolf" ]; then
            set_kill_keys "ecwolf"
            CONTROLLERCONFIG="${arguments#*--controllers=*}"
            RUNTHIS='${TBASH} ecwolf.sh "${ROMNAME}" --controllers="${CONTROLLERCONFIG}"'
        fi
        ;;
        "gmloader")
            set_kill_keys "gmloader"
            CONTROLLERCONFIG="${arguments#*--controllers=*}"
            RUNTHIS='${TBASH} gmloader.sh "${ROMNAME}" --controllers="${CONTROLLERCONFIG}"'
        ;;
        "intellivision")
        if [ "${EMU}" = "jzintv" ]; then
            set_kill_keys "jzintv"
            RUNTHIS='jzintv.sh "${ROMNAME}"'
        fi
        ;;
        "saturn")
        if [ "${EMU}" = "yabasanshiroSA" ]; then
            set_kill_keys "yabasanshiro"
            RUNTHIS='yabasanshiro.sh "${ROMNAME}"'
        fi
        ;;
        esac
elif [ ${LIBRETRO} == "yes" ]; then
# We are running a Libretro emulator set all the settings that we chose on ES

if [[ ${PLATFORM} == "ports" ]]; then
        PORTCORE="${arguments##*-C}"  # read from -C onwards
        EMU="${PORTCORE%% *}_libretro"  # until a space is found
        PORTSCRIPT="${arguments##*-SC}"  # read from -SC onwards
    ROMNAME_SHADER=${PORTSCRIPT}
else
    ROMNAME_SHADER=${ROMNAME}
fi

RUNTHIS='${RABIN} ${VERBOSE} -L /tmp/cores/${EMU}.so --config ${RACONF} "${ROMNAME}"'
CONTROLLERCONFIG="${arguments#*--controllers=*}"

if [[ "${arguments}" == *"-state_slot"* ]]; then
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% -state_slot*}"  # until -state_slot is found
    SNAPSHOT="${arguments#*-state_slot *}" # -state_slot x ...
    SNAPSHOT="${SNAPSHOT%% -*}"  # we only need the state_slot
else
   SNAPSHOT=""
fi

if [[ "${arguments}" == *"-autosave"* ]]; then
    CONTROLLERCONFIG="${CONTROLLERCONFIG%% -autosave*}"  # until -autosave is found
    AUTOSAVE="${arguments#*-autosave *}" # -autosave x ...
    AUTOSAVE="${AUTOSAVE%% -*}" # we only need autosave
else
    AUTOSAVE="0"
fi

CORE=${EMU%%_*}

# Netplay

# make sure the ip and port are blank
set_ee_setting "netplay.server.ip" "disable"
set_ee_setting "netplay.server.port" "disable"
set_ee_setting "netplay.mode" "disable"

# check if we started as host for a game
if [[ "${arguments}" == *"--host"* ]]; then
    NETPLAY="${arguments##*--host}"  # read from --host onwards
    NETPLAY="${NETPLAY%%--nick*}"  # until --nick is found
    NETPLAY="--host ${NETPLAY} --nick"
fi

# check if we are trying to connect to a client on netplay
if [[ "${arguments}" == *"--connect"* ]]; then
    NETPLAY="${arguments##*--connect}"  # read from --connect onwards
    NETPLAY="${NETPLAY%%--nick*}"  # until --nick is found
    NETPLAY="--connect ${NETPLAY} --nick"
    set_ee_setting "netplay.mode" "client"
fi

# check if we are trying to connect as spectator on netplay
if [[ "${arguments}" == *"--netplaymode spectator"* ]]; then
    set_ee_setting "netplay.mode" "spectator"
fi

if [[ ${NETPLAY} != "No" ]]; then
    NETPLAY_NICK=$(get_ee_setting netplay.nickname)
    [[ -z "${NETPLAY_NICK}" ]] && NETPLAY_NICK="Anonymous"
    NETPLAY="$(echo ${NETPLAY} | sed "s|--nick|--nick \"${NETPLAY_NICK}\"|")"
    RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${NETPLAY} --config|")

    if [[ "${NETPLAY}" == *"connect"* ]]; then
        NETPLAY_PORT="${arguments##*--port }"  # read from -netplayport  onwards
        NETPLAY_PORT="${NETPLAY_PORT%% *}"  # until a space is found
        NETPLAY_IP="${arguments##*--connect }"  # read from -netplayip  onwards
        NETPLAY_IP="${NETPLAY_IP%% *}"  # until a space is found
        set_ee_setting "netplay.server.ip" "${NETPLAY_IP}"
        set_ee_setting "netplay.server.port" "${NETPLAY_PORT}"
    fi
fi
# End netplay

SHADERSET=$(setsettings.sh "${PLATFORM}" "${ROMNAME_SHADER}" "${CORE}" --controllers="${CONTROLLERCONFIG}" --autosave="${AUTOSAVE}" --snapshot="${SNAPSHOT}")
#echo ${SHADERSET} # Only needed for debug

if [[ ${SHADERSET} != 0 ]]; then
    RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${SHADERSET} --config|")
fi

# we check is maxperf is set only if OGA OC is off
OGAOC=$(get_ee_setting ee_oga_oc)
[ -z "${OGAOC}" ] && OGAOC="Off"

if [[ "${OGAOC}" == "Off" ]]; then
    if [ $(get_ee_setting "maxperf" "${PLATFORM}" "${BASEROMNAME}") == "0" ]; then
        normperf
    else
        maxperf
    fi
fi

else # Retrorun was selected
# Retrotun does not support settings
    RUNTHIS="retrorun"
    if [ "${BIT32}" == "yes" ]; then
        RUNTHIS+="32"
    fi

		JOY_FILE=$(ls "/dev/input/by-path/*-event-joystick" )
    if [[ -f "${JOY_FILE}" ]]; then
            ln -s /dev/input/event2 ${JOY_FILE}
    fi

    RUNTHIS+=' ${CMD_ROTATE} --triggers -g -d /storage/roms/bios /tmp/cores/${EMU}.so "${ROMNAME}"'

fi # end Libretro/retrorun or standalone emu logic

if [ "${USELOG}" == "1" ]; then # No need to do all this if log is disabled
    # Clear the log file
    echo "EmuELEC Run Log" > ${EMUELECLOG}
    cat /etc/motd >> ${EMUELECLOG}

    [[ "${NETPLAY}" == *"connect"* ]] && echo "Netplay client!" >> ${EMUELECLOG}

    # Write the command to the log file.
    echo "PLATFORM: ${PLATFORM}" >> ${EMUELECLOG}
    echo "ROM NAME: ${ROMNAME}" >> ${EMUELECLOG}
    echo "BASE ROM NAME: ${ROMNAME##*/}" >> ${EMUELECLOG}
    echo "USING CONFIG: ${RACONF}" >> ${EMUELECLOG}
    echo "1st Argument: ${1}" >> ${EMUELECLOG}
    echo "2nd Argument: ${2}" >> ${EMUELECLOG}
    echo "3rd Argument: ${3}" >> ${EMUELECLOG}
    echo "4th Argument: ${4}" >> ${EMUELECLOG}
    echo "Full arguments: ${arguments}" >> ${EMUELECLOG}
    echo "Run Command is:" >> ${EMUELECLOG}
    eval echo ${RUNTHIS} >> ${EMUELECLOG}
fi

gptokeyb 1 ${KILLTHIS} ${VIRTUAL_KB} -killsignal ${KILLSIGNAL} &

[[ "${CLOUD_SYNC}" == "1" ]] && wait ${CLOUD_PID}

# Execute the command and try to output the results to the log file if it was not disabled.
if [[ ${LOGEMU} == "Yes" ]]; then
   echo "Emulator Output is:" >> ${EMUELECLOG}
   eval ${RUNTHIS} >> ${EMUELECLOG} 2>&1
   ret_error=${?}
else
   echo "Emulator log was dissabled" >> ${EMUELECLOG}
   eval ${RUNTHIS} > /dev/null 2>&1
   ret_error=${?}
fi

#blank_buffer

# clear terminal window
        reset > /dev/tty < /dev/null 2>&1
        reset > /dev/tty0 < /dev/null 2>&1
        reset > /dev/tty1 < /dev/null 2>&1
        reset > /dev/console < /dev/null 2>&1

emuelec-utils end_app_video

emuelec-utils set_rotation "0" "${EMULATOR}"

# Kill MIDI Processes
emuelec-utils set_midi_source "None" "${EMULATOR}"

[[ "${CLOUD_SYNC}" == "1" ]] && ra_rclone.sh set "${PLATFORM}" "${ROMNAME}" &

# Just in case
kill_video_controls

# Just for good measure lets make a symlink to Retroarch logs if it exists
if [[ -f "/storage/.config/retroarch/retroarch.log" ]] && [[ ! -e "${LOGSDIR}/retroarch.log" ]]; then
        ln -sf /storage/.config/retroarch/retroarch.log ${LOGSDIR}/retroarch.log
fi

#{log_addon}#

# reset audio to default
set_audio default

if [[ "${BTENABLED}" == "1" ]]; then
        # Restart the bluetooth agent
    systemctl start bluetooth-agent
fi

if [ "${EE_DEVICE}" == "OdroidGoAdvance" ]; then
# To avoid screwing up the gamepad configuration after setting vertical mode we return the config to horizontal

        case "$(oga_ver)" in
            "OGA")
                if [ -f "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg" ]; then
                    mv "/tmp/joypads/GO-Advance Gamepad.cfg" "/tmp/joypads/GO-Advance Gamepad_vertical.cfg"
                    mv "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg" "/tmp/joypads/GO-Advance Gamepad.cfg"
                fi
            ;;
            "OGABE")
                if [ -f "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg" ]; then
                    mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg"
                    mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg"
                fi
            ;;
            "OGS")
                if [ -f "/tmp/joypads/GO-Super Gamepad_horizontal.cfg" ]; then
                    mv "/tmp/joypads/GO-Super Gamepad.cfg" "/tmp/joypads/GO-Super Gamepad_vertical.cfg"
                    mv "/tmp/joypads/GO-Super Gamepad_horizontal.cfg" "/tmp/joypads/GO-Super Gamepad.cfg"
                fi
            ;;
        esac
fi

# Dolphin does not like to be killed?
[[ "${EMU}" = "dolphin" ]] && ret_error="0"

# Chocolate Doom does not like to be killed?
[[ "${EMU}" = "Chocolate-Doom" ]] && ret_error="0"

# YabasanshiroSA does not like to be killed?
[[ "${EMU}" = "yabasanshiroSA" ]] && ret_error="0"

# Temp fix for retrorun always erroing out on exit
[[ "${RETRORUN}" == "yes" ]] && ret_error=0

# Temp fix for libretro scummvm always erroing out on exit
[[ "${EMU}" == *"scummvm_libretro"* ]] && ret_error=0

[[ "${CLOUD_SYNC}" == "1" ]] && wait ${CLOUD_PID}

end_game

if [[ "${ret_error}" != "0" ]]; then
    echo "exit ${ret_error}" >> ${EMUELECLOG}
    ret_bios=0

    # Check for missing bios if needed
    REQUIRESBIOS=(atari5200 atari800 atari7800 atarilynx colecovision amiga amigacd32 o2em intellivision pcengine pcenginecd pcfx fds segacd saturn dreamcast naomi atomiswave x68000 neogeo neogeocd msx msx2 sc-3000)

    (for e in "${REQUIRESBIOS[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RB=0 || RB=1
        if [ ${RB} == 0 ]; then
            CBPLATFORM="${PLATFORM}"
            [[ "${CBPLATFORM}" == "msx2" ]] && CBPLATFORM="msx"
            [[ "${CBPLATFORM}" == "pcenginecd" ]] && CBPLATFORM="pcengine"
            [[ "${CBPLATFORM}" == "amigacd32" ]] && CBPLATFORM="amiga"
            ee_check_bios "${CBPLATFORM}" "${CORE}" "${EMULATOR}" "${ROMNAME}" "${EMUELECLOG}"
            ret_bios=${?}
            echo "exit bios ${ret_bios}" >> ${EMUELECLOG}
        fi #require bios ends

    # Since the error was not because of missing BIOS but we did get an error, display the log to find out
    [[ "${ret_bios}" == "0" ]] && text_viewer -e -w -t "Error! ${PLATFORM}-${EMULATOR}-${CORE}-${ROMNAME}" -f 24 ${EMUELECLOG}
    blank_buffer
    exit 1
else
    echo "exit 0" >> ${EMUELECLOG}
    blank_buffer
    exit 0
fi
