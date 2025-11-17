#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# I use ${} for easier reading

# IMPORTANT: This script should not return (echo) anything other than the shader if its set

. /etc/profile

LOGGING=0
[[ "$(get_es_setting string LogLevel)" == "debug" ]] && LOGGING=1
LOG=/emuelec/logs/setsettings.log

RETROARCHIVEMENTS=(3do arcade atari2600 atari7800 atarilynx coleco colecovision famicom fbn fbneo fds gamegear gb gba gbc lynx mame genesis mastersystem megadrive megadrive-japan msx n64 neogeo nes ngp pcengine pcfx pokemini psx saturn sega32x segacd sfc sg-1000 snes tg16 vectrex virtualboy wonderswan)
NOREWIND=(sega32x zxspectrum odyssey2 mame n64 dreamcast atomiswave naomi neogeocd saturn psp pspminis)
NORUNAHEAD=(psp sega32x n64 dreamcast atomiswave naomi neogeocd saturn)

INDEXRATIOS=(4/3 16/9 16/10 16/15 21/9 1/1 2/1 3/2 3/4 4/1 9/16 5/4 6/5 7/9 8/3 8/7 19/12 19/14 30/17 32/9 config squarepixel core custom full)
CONF="/storage/.config/emuelec/configs/emuelec.conf"
export RA_CONF="/storage/.config/retroarch/retroarch.cfg"
RACORECONF="/storage/.config/retroarch/retroarch-core-options.cfg"

TMP_RACONF="/tmp/ra_merge_settings.cfg"
RACONF="${TMP_RACONF}"

if [ "${LOGGING}" ]; then 
echo "Setsettings Log ${RACONF}" > "${LOG}"
fi

PLATFORM=${1,,}
CORE=${3,,}
ROM="${2##*/}"
ROM="$(printf '%s' "${ROM}" | sed 's/\([][]\)/\\\1/g')"
SETF=0
SHADERSET=0
AUTOLOAD="false"

#bezels
ISBEZEL="false"
IRBEZEL="22"

#Autosave
AUTOSAVE="$@"
AUTOSAVE="${AUTOSAVE#*--autosave=*}"
AUTOSAVE="${AUTOSAVE% --*}"

#Snapshot
SNAPSHOT="$@"
SNAPSHOT="${SNAPSHOT#*--snapshot=*}"
SNAPSHOT="${SNAPSHOT% --*}"


write_log() {
	local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
	[[ "${LOGGING}" ]] && echo "${timestamp} : ${1}" >> "${LOG}"
}

# Helper function: check if array contains value
array_contains() {
    local seeking=$1; shift
    local element
    for element; do
        [[ "$element" == "$seeking" ]] && return 0
    done
    return 1
}

# Helper function: write boolean setting
write_bool() {
    local key=$1
    local value=$2
    [ "$value" == "1" ] && echo "${key} = \"true\"" >> ${RACONF} || echo "${key} = \"false\"" >> ${RACONF}
}

#Self language retroarch
EE_LANG=$(get_ee_setting system.language)

case "${EE_LANG}" in
    pt_BR|pt_PT) LANGEMUELEC="7" ;;
    en_US|en_GB) LANGEMUELEC="0" ;;
    fr_FR)       LANGEMUELEC="2" ;;
    es_ES|es_MX) LANGEMUELEC="3" ;;
    de_DE)       LANGEMUELEC="4" ;;
    it_IT)       LANGEMUELEC="5" ;;
    eu_ES)       LANGEMUELEC="21" ;;
    tr_TR)       LANGEMUELEC="17" ;;
    zh_CN)       LANGEMUELEC="11" ;;
    zh_TW)       LANGEMUELEC="12" ;;
    ko_KR)       LANGEMUELEC="8" ;;
    ja_JP)       LANGEMUELEC="9" ;;
    ru_RU)       LANGEMUELEC="14" ;;
    nl_NL)       LANGEMUELEC="10" ;;
    pl_PL)       LANGEMUELEC="15" ;;
    sv_SE)       LANGEMUELEC="16" ;;
    hu_HU)       LANGEMUELEC="19" ;;
    cs_CZ)       LANGEMUELEC="20" ;;
    *)           LANGEMUELEC="0" ;;
esac

echo "user_language = ${LANGEMUELEC}" >> ${TMP_RACONF}

write_log "Set Language to ${EE_LANG} Retroarch: ${LANGEMUELEC}"

# For the new snapshot save state manager we need to set the path to be /storage/roms/savestates/[PLATFORM]
mkdir -p "/storage/roms/savestates/${PLATFORM}"

cat >> ${RACONF} << EOF
savestates_in_content_dir = "false"
sort_savefiles_by_content_enable = "false"
sort_savefiles_enable = "false"
sort_savestates_by_content_enable = "false"
sort_savestates_enable = "false"
savestate_directory = "/storage/roms/savestates/${PLATFORM}"
EOF

function default_settings() {
# IMPORTANT: Every setting we change should have a default value here
    cat >> ${RACONF} << EOF
video_scale_integer = "false"
video_scale_integer_overscale = "false"
video_shader = ""
video_shader_enable = "false"
video_smooth = "false"
aspect_ratio_index = "22"
rewind_enable = "false"
run_ahead_enabled = "false"
run_ahead_frames = "1"
run_ahead_secondary_instance = "false"
savestate_auto_save = "false"
savestate_auto_load = "false"
cheevos_enable = "false"
cheevos_username = ""
cheevos_password = ""
cheevos_hardcore_mode_enable = "false"
cheevos_start_active = "false"
cheevos_leaderboards_enable = "false"
cheevos_verbose_enable = "false"
cheevos_auto_screenshot = "false"
ai_service_mode = "0"
ai_service_enable = "false"
ai_service_source_lang = "0"
ai_service_url = ""
input_libretro_device_p1 = "1"
fps_show = "false"
netplay = "false"
video_oga_vertical_enable = "false"
video_ogs_vertical_enable = "false"
video_ctx_scaling = "false"
video_frame_delay_auto = "false"
EOF
}

function set_setting() {
# we set the setting on the configuration file

write_log "Called \"${1}\" with \"${2}\""

case ${1} in
    "ratio")
    if [[ -z "${2}" || "${2}" == "none" || "${2}" == "0" ]]; then
        # 22 is the "Core Provided" aspect ratio and its set by default if no other is selected
        echo 'aspect_ratio_index = "22"' >> ${RACONF}
    else
    for i in "${!INDEXRATIOS[@]}"; do
        if [[ "${INDEXRATIOS[${i}]}" = "${2}" ]]; then
            break
        fi
    done
        echo "aspect_ratio_index = \"${i}\""  >> ${RACONF}
        IRBEZEL="${i}"
    fi
    ;;
    "smooth")
        write_bool "video_smooth" "${2}"
    ;;
    "rewind")
        if array_contains "${PLATFORM}" "${NOREWIND[@]}"; then
            echo 'rewind_enable = "false"' >> ${RACONF}
        else
            write_bool "rewind_enable" "${2}"
        fi
    ;;
    "autosave")
        if [[ -z "${AUTOSAVE}" || "${AUTOSAVE}" == "0" ]]; then
            echo 'savestate_auto_save = "false"' >> ${RACONF}
            echo 'savestate_auto_load = "false"' >> ${RACONF}
        else
        write_log "Autosave ${AUTOSAVE}"
            echo 'savestate_auto_save = "true"' >> ${RACONF}
            echo 'savestate_auto_load = "true"' >> ${RACONF}
            AUTOLOAD="true"
        fi
    ;;
    "snapshot")
        if [[ ! -z "${SNAPSHOT}" ]]; then
            echo "state_slot = \"${SNAPSHOT}\"" >> ${RACONF}
        else
            if [[ "${AUTOLOAD}" == "false" ]]; then
                echo 'savestate_auto_save = "false"' >> ${RACONF}
                echo 'savestate_auto_load = "false"' >> ${RACONF}
            fi
            echo 'state_slot = "0"' >> ${RACONF}
        fi
    ;;
    "integerscale")
        write_bool "video_scale_integer" "${2}"
        [ "${2}" == "1" ] && ISBEZEL="true" || ISBEZEL="false"
    ;;
    "integerscaleoverscale")
		case "${2}" in
			"1")
				echo 'video_scale_integer_scaling = "1"' >> "${RACONF}"
				echo 'video_scale_integer_axis = "1"' >> "${RACONF}"
			;;
			"2")
				echo 'video_scale_integer_scaling = "2"' >> "${RACONF}"
				echo 'video_scale_integer_axis = "1"' >> "${RACONF}"
			;;
			*)
				echo 'video_scale_integer_overscale = "0"' >> "${RACONF}"
				echo 'video_scale_integer_axis = "0"' >> "${RACONF}"
			;;
esac
    ;;
    "rgascale")
        write_bool "video_ctx_scaling" "${2}"
    ;;
    "shaderset")
        if [[ -z "${2}" || "${2}" == "none" || "${2}" == "0" ]]; then
            echo 'video_shader_enable = "false"' >> ${RACONF}
            echo 'video_shader = ""' >> ${RACONF}
        else
            echo "video_shader = \"${2}\"" >> ${RACONF}
            echo 'video_shader_enable = "true"' >> ${RACONF}
            echo "--set-shader /tmp/shaders/${2}"
        fi
    ;;
    "runahead")
    if ! array_contains "${PLATFORM}" "${NORUNAHEAD[@]}"; then
        if [[ -z "${2}" || "${2}" == "none" || "${2}" == "0" ]]; then
            echo 'run_ahead_enabled = "false"' >> ${RACONF}
            echo 'run_ahead_frames = "1"' >> ${RACONF}
        else
            echo 'run_ahead_enabled = "true"' >> ${RACONF}
            echo "run_ahead_frames = \"${2}\"" >> ${RACONF}
        fi
	fi
    ;;
    "secondinstance")
        if ! array_contains "${PLATFORM}" "${NORUNAHEAD[@]}"; then
        write_bool "run_ahead_secondary_instance" "${2}"
        fi
    ;;
    "video_frame_delay_auto")
        write_bool "video_frame_delay_auto" "${2}"
    ;;
    "ai_service_enabled")
        if [[ -z "${2}" || "${2}" == "none" || "${2}" == "0" ]]; then
            echo 'ai_service_enable = "false"' >> ${RACONF}
        else
            echo 'ai_service_enable = "true"' >> ${RACONF}
            AI_LANG=$(get_setting "ai_target_lang")
            AI_URL=$(get_setting "ai_service_url")
            [[ -z "${AI_LANG}" ]] && AI_LANG="0"
            echo "ai_service_source_lang = \"${AI_LANG}\"" >> ${RACONF}
            if [[ -z "${AI_URL}" || "${AI_URL}" == "auto" || "${AI_URL}" == "none" ]]; then
                echo "ai_service_url = \"http://ztranslate.net/service?api_key=BATOCERA&mode=Fast&output=png&target_lang=${AI_LANG}\"" >> ${RACONF}
            else
                echo "ai_service_url = \"${AI_URL}&mode=Fast&output=png&target_lang=${AI_LANG}\"" >> ${RACONF}
            fi
        fi
    ;;
    "retroachievements")
        if [[ $(array_contains "${PLATFORM}" "${RETROARCHIVEMENTS[@]}") && "${2}" == "1" ]]; then
            # Batch read all retroachievements settings at once
            local RA_USER=$(get_setting "retroachievements.username")
            local RA_PASS=$(get_setting "retroachievements.password")
            local RA_HARD=$(get_setting "retroachievements.hardcore")
            local RA_ENCORE=$(get_setting "retroachievements.encore")
            local RA_LEAD=$(get_setting "retroachievements.leaderboards")
            local RA_VERB=$(get_setting "retroachievements.verbose")
            local RA_SCREEN=$(get_setting "retroachievements.screenshot")
            
            echo 'cheevos_enable = "true"' >> ${RACONF}
            echo "cheevos_username = \"${RA_USER}\""  >> ${RACONF}
            echo "cheevos_password = \"${RA_PASS}\""  >> ${RACONF}
                    # retroachievements_hardcore_mode
            write_bool "cheevos_hardcore_mode_enable" "${RA_HARD}"
                    # retroachievements_encore_mode
            write_bool "cheevos_start_active" "${RA_ENCORE}"
                    # retroachievements_leaderboards
            write_bool "cheevos_leaderboards_enable" "${RA_LEAD}"
                    # retroachievements_verbose_mode
            write_bool "cheevos_verbose_enable" "${RA_VERB}"
                    # retroachievements_automatic_screenshot
            write_bool "cheevos_auto_screenshot" "${RA_SCREEN}"
            if [ "${RA_SCREEN}" == "1" ]; then 
				echo 'cheevos_auto_screenshot = "true"' >> ${RACONF}
				echo 'screenshot_directory = "/roms/screenshots"' >> ${RACONF}
				mkdir -p "/roms/screenshots"
            else
				echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
            fi
		else
            cat >> ${RACONF} << EOF
cheevos_enable = "false"
cheevos_username = ""
cheevos_password = ""
cheevos_hardcore_mode_enable = "false"
cheevos_start_active = "false"
cheevos_leaderboards_enable = "false"
cheevos_verbose_enable = "false"
cheevos_auto_screenshot = "false"
EOF
        fi
    ;;
    "netplay")
        if [[ -z "${2}" || "${2}" == "none" || "${2}" == "0" ]]; then
            echo 'netplay = "false"' >> ${RACONF}
        else
            echo 'netplay = "true"' >> ${RACONF}
            
            # Batch read netplay settings
            local NP_MODE=$(get_setting "netplay.mode")
            local NP_PORT=$(get_setting "netplay.port")
            local NP_IP=$(get_setting "netplay.server.ip")
            local NP_SPORT=$(get_setting "netplay.server.port")
            local NP_PASS=$(get_setting "netplay.password")
            local NP_SPASS=$(get_setting "netplay.spectatepassword")
            local NP_PUBLIC=$(get_setting "netplay_public_announce")
            local NP_RELAY=$(get_setting "netplay.relay")
            local NP_FRAMES=$(get_setting "netplay.frames")
            local NP_NICK=$(get_setting "netplay.nickname")

        # Security : hardcore mode disables save states, which would kill netplay
	# double check if this is not a duplicated entry when it 
            echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}

            if [[ "${NP_MODE}" == "host" ]]; then
        # Quite strangely, host mode requires netplay_mode to be set to false when launched from command line
                echo 'netplay_mode = "false"' >> ${RACONF}
                echo 'netplay_client_swap_input = "false"' >> ${RACONF}
                echo "netplay_ip_port = \"${NP_PORT}\"" >> ${RACONF}
            elif [[ "${NP_MODE}" == "client" || "${NP_MODE}" == "spectator" ]]; then
        # But client needs netplay_mode = true ... bug ?
                echo 'netplay_mode = "true"' >> ${RACONF}
                echo "netplay_ip_address = \"${NP_IP}\"" >> ${RACONF}
                echo "netplay_ip_port = \"${NP_SPORT}\"" >> ${RACONF}
                echo 'netplay_client_swap_input = "true"' >> ${RACONF}
            fi

            [[ "${NP_MODE}" == "spectator" ]] && echo 'netplay_start_as_spectator = "true"' >> ${RACONF}

            if [[ -n "${NP_PASS}" && "${NP_PASS}" != "none" && "${NP_PASS}" != "false" ]]; then
                echo "netplay_password = \"${NP_PASS}\"" >> ${RACONF}
            fi

            if [[ -n "${NP_SPASS}" && "${NP_SPASS}" != "none" && "${NP_SPASS}" != "false" ]]; then
                echo "netplay_spectate_password = \"${NP_SPASS}\"" >> ${RACONF}
            fi

        # Netplay hide the gameplay
            if [[ -n "${NP_PUBLIC}" && "${NP_PUBLIC}" != "none" && "${NP_PUBLIC}" != "false" ]]; then
                echo 'netplay_public_announce = "true"' >> ${RACONF}
            else
                echo 'netplay_public_announce = "false"' >> ${RACONF}
            fi

            if [[ -n "${NP_RELAY}" && "${NP_RELAY}" != "none" && "${NP_RELAY}" != "false" ]]; then
                echo 'netplay_use_mitm_server = "true"'  >> ${RACONF}
                echo "netplay_mitm_server = \"${NP_RELAY}\"" >> ${RACONF}
            else
                echo 'netplay_use_mitm_server = "false"' >> ${RACONF}
            fi

            echo "netplay_delay_frames = \"${NP_FRAMES}\"" >> ${RACONF}
            echo "netplay_nickname = \"${NP_NICK}\"" >> ${RACONF}
        fi
    ;;
    "fps")
    # Display FPS in Retroarch
        local SHOWFPS=$(get_setting "showFPS")
        write_bool "fps_show" "${SHOWFPS}"
    ;;
    "vertical")
    # Vertical orientation game
    if [ "${2}" == "1" ]; then
        echo 'video_oga_vertical_enable = "true"' >> ${RACONF}
   
            local VERT_ASP=$(get_setting "vert_aspect")
            if [[ -z "${VERT_ASP}"  || "${VERT_ASP}" == "none" || "${VERT_ASP}" == "0" || "${VERT_ASP}" == "1" ]]; then
                echo 'aspect_ratio_index = "1"' >> ${RACONF}
                IRBEZEL="1"
            else
                echo "aspect_ratio_index = \"${VERT_ASP}\"" >> ${RACONF}
                IRBEZEL="${VERT_ASP}"
            fi
            
            case "$(oga_ver)" in
                "OGA")
                    [ -f "/tmp/joypads/GO-Advance Gamepad_vertical.cfg" ] && {
                        mv "/tmp/joypads/GO-Advance Gamepad.cfg" "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg"
                        mv "/tmp/joypads/GO-Advance Gamepad_vertical.cfg" "/tmp/joypads/GO-Advance Gamepad.cfg"
                    }
                ;;
                "OGABE")
                    [ -f "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg" ] && {
                        mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg"
                        mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg"
                    }
                ;;
                "OGS")
                    echo 'video_ogs_vertical_enable = "true"' >> ${RACONF}
                    [ -f "/tmp/joypads/GO-Super Gamepad_vertical.cfg" ] && {
                        mv "/tmp/joypads/GO-Super Gamepad.cfg" "/tmp/joypads/GO-Super Gamepad_horizontal.cfg"
                        mv "/tmp/joypads/GO-Super Gamepad_vertical.cfg" "/tmp/joypads/GO-Super Gamepad.cfg"
                    }
                ;;
            esac
        else
            echo 'video_oga_vertical_enable = "false"' >> ${RACONF}
            echo 'video_ogs_vertical_enable = "false"' >> ${RACONF}

            case "$(oga_ver)" in
                "OGA")
                    [ -f "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg" ] && {
                        mv "/tmp/joypads/GO-Advance Gamepad.cfg" "/tmp/joypads/GO-Advance Gamepad_vertical.cfg"
                        mv "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg" "/tmp/joypads/GO-Advance Gamepad.cfg"
                    }
                ;;
                "OGABE")
                    [ -f "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg" ] && {
                        mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg"
                        mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg"
                    }
                ;;
                "OGS")
                    [ -f "/tmp/joypads/GO-Super Gamepad_horizontal.cfg" ] && {
                        mv "/tmp/joypads/GO-Super Gamepad.cfg" "/tmp/joypads/GO-Super Gamepad_vertical.cfg"
                        mv "/tmp/joypads/GO-Super Gamepad_horizontal.cfg" "/tmp/joypads/GO-Super Gamepad.cfg"
                    }
                ;;
            esac
        fi
    ;;
esac
}

function get_setting() {
   ees -e -r "${1}" -p "${PLATFORM}" -m "${ROM}"
}

for s in ratio smooth shaderset rewind autosave integerscale integerscaleoverscale runahead secondinstance video_frame_delay_auto retroachievements ai_service_enabled netplay fps vertical rgascale snapshot; do
EES=$(get_setting ${s})
set_setting "${s}" "${EES}"
[ -z "${EES}" ] || SETF=1
done

# If no setting was changed, set all options to default on the configuration files
[ ${SETF} == 0 ] && default_settings

# Core-specific configurations, these settings should probably be moved to other file or script
# TODO: Need to check if file exists first, it may contain other settings that we do not want to remove.
if [ "${CORE}" == "atari800" ]; then
ATARICONF="/storage/.config/emuelec/configs/atari800.cfg"
ATARI800CONF="/storage/.config/retroarch/config/Atari800/Atari800.opt"

    if [ "${PLATFORM}" == "atari5200" ]; then
        cat > "${ATARI800CONF}" << EOF
atari800_system = "5200"
EOF
        cat > "${ATARICONF}" << EOF
RAM_SIZE=16
STEREO_POKEY=0
BUILTIN_BASIC=0
EOF
        echo 'atari800_system = "5200"' >> ${RACORECONF}
    else
        cat > "${ATARI800CONF}" << EOF
atari800_system = "800XL (64K)"
EOF
        cat > "${ATARICONF}" << EOF
RAM_SIZE=64
STEREO_POKEY=1
BUILTIN_BASIC=1
EOF
        echo 'atari800_system = "800XL (64K)"' >> ${RACORECONF}
    fi
fi

if [ "${PLATFORM}" == "amstradgx4000" ]; then
# Make sure cap32_model is set to "6128+ (experimental)"
CAP32CONF="/storage/.config/retroarch/config/cap32/cap32.opt"
    cat > "${CAP32CONF}" << EOF
cap32_model = "6128+ (experimental)"
cap32_gfx_colors = "24bit"
EOF
fi

if [ "${PLATFORM}" == "amstradcpc" ]; then
# But amstradcpc wants cap32_model set to "6128"
CAP32CONF="/storage/.config/retroarch/config/cap32/cap32.opt"
   cat > "${CAP32CONF}" << EOF
cap32_model = "6128"
cap32_gfx_colors = "16bit"
EOF
fi

if [ "${CORE}" == "gambatte" ]; then
GAMBATTECONF="/storage/.config/retroarch/config/Gambatte/Gambatte.opt"
    COLORIZE=$(get_setting "renderer.colorization")
    
    write_log "Gambatte Colorization: ${COLORIZE}"
    
    if [[ -z "${COLORIZE}" || "${COLORIZE}" == "auto"  ||  "${COLORIZE}" == "none" ]]; then
        cat > "${GAMBATTECONF}" << EOF
gambatte_gb_colorization = "disabled"
gambatte_gb_internal_palette = ""
EOF
        cat >> ${RACORECONF} << EOF
gambatte_gb_colorization = "disabled"
gambatte_gb_internal_palette = ""
EOF
    elif [ "${COLORIZE}" == "GBC" ]; then
        cat > "${GAMBATTECONF}" << EOF
gambatte_gb_colorization = "GBC"
gambatte_gb_internal_palette = ""
EOF
        cat >> ${RACORECONF} << EOF
gambatte_gb_colorization = "GBC"
gambatte_gb_internal_palette = ""
EOF
    elif [ "${COLORIZE}" == "SGB" ]; then
        cat > "${GAMBATTECONF}" << EOF
gambatte_gb_colorization = "SGB"
gambatte_gb_internal_palette = ""
EOF
        cat >> ${RACORECONF} << EOF
gambatte_gb_colorization = "SGB"
gambatte_gb_internal_palette = ""
EOF
    elif [ "${COLORIZE}" == "Best Guess" ]; then
        cat > "${GAMBATTECONF}" << EOF
gambatte_gb_colorization = "auto"
gambatte_gb_internal_palette = ""
EOF
        cat >> ${RACORECONF} << EOF
gambatte_gb_colorization = "auto"
gambatte_gb_internal_palette = ""
EOF
    else
        cat > "${GAMBATTECONF}" << EOF
gambatte_gb_colorization = "internal"
gambatte_gb_internal_palette = "${COLORIZE}"
EOF
        cat >> ${RACORECONF} << EOF
gambatte_gb_colorization = "internal"
gambatte_gb_internal_palette = "${COLORIZE}"
EOF
    fi
fi

# We set up the controller index
CONTROLLERS="$@"
CONTROLLERS="${CONTROLLERS#*--controllers=*}"
CONTROLLERS="${CONTROLLERS%% --autosave*}"  # until --autosave is found

for i in 1 2 3 4 5; do
if [[ "${CONTROLLERS}" == *p${i}* ]]; then
PINDEX="${CONTROLLERS#*-p${i}index }"
PINDEX="${PINDEX%% -p${i}guid*}"
echo "input_player${i}_joypad_index = \"${PINDEX}\"" >> ${RACONF}

# Setting controller type for different cores
        [ "${PLATFORM}" == "atari5200" ] && echo "input_libretro_device_p${i} = \"513\"" >> ${RACONF}
    fi
done

# EE Device detection
read -r EE_DEVICE < /ee_arch
MENU_DRV=$(get_setting "retroarch.menu_driver")

write_log "Menu driver ${MENU_DRV} for ${EE_DEVICE}"

if [[ -z "${MENU_DRV}"  ||  "${MENU_DRV}" == "auto"  ||  "${MENU_DRV}" == "none"  ||  "${MENU_DRV}" == "0" ]]; then
    if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
        MENU_DRV="xmb"
    else
        MENU_DRV="ozone"
    fi
fi

[[ -z "${MENU_DRV}" ]] && MENU_DRV="ozone"

echo "menu_driver = \"${MENU_DRV}\"" >> ${RACONF}

# Show bezel if enabled
BEZEL_SET=$(get_setting "bezel")
if [[ -z "${BEZEL_SET}" || "${BEZEL_SET}" == "none"  ||  "${BEZEL_SET}" == "0" ]]; then
    ${TBASH} bezels.sh "none" "default" "${ISBEZEL}" "${IRBEZEL}"
else
    ${TBASH} bezels.sh "${PLATFORM}" "${ROM}" "${ISBEZEL}" "${IRBEZEL}"
fi

inverted_ok_cancel=$(get_es_setting bool InvertButtons)
[[ ${inverted_ok_cancel} == "true" ]] || inverted_ok_cancel="false"
echo "menu_swap_ok_cancel_buttons = \"${inverted_ok_cancel}\"" >> ${RACONF}

echo "cheevos_unsupported_notification = \"false\"" >> ${RACONF}

# Merge the changes to: /storage/.config/retroarch/retroarch.cfg 
ees -i ${RACONF}

if [[ "${LOGGING}" == "1" ]]; then
write_log "- merged settings to retroarch.cfg -"
cat "${RACONF}" >> "${LOG}"
fi
 
rm ${RACONF}
