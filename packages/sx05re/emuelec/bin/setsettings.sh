#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# I use ${} for easier reading

# IMPORTANT: This script should not return (echo) anything other than the shader if its set

. /etc/profile

RETROARCHIVEMENTS=(3do arcade atari2600 atari7800 atarilynx coleco colecovision famicom fbn fbneo fds gamegear gb gba gbc lynx mame genesis mastersystem megadrive megadrive-japan msx n64 neogeo nes ngp pcengine pcfx pokemini psx saturn sega32x segacd sfc sg-1000 snes tg16 vectrex virtualboy wonderswan)
NOREWIND=(sega32x zxspectrum odyssey2 mame n64 dreamcast atomiswave naomi neogeocd saturn psp pspminis)
NORUNAHEAD=(psp sega32x n64 dreamcast atomiswave naomi neogeocd saturn)

INDEXRATIOS=(4/3 16/9 16/10 16/15 21/9 1/1 2/1 3/2 3/4 4/1 9/16 5/4 6/5 7/9 8/3 8/7 19/12 19/14 30/17 32/9 config squarepixel core custom full)
CONF="/storage/.config/emuelec/configs/emuelec.conf"
RACONF="/storage/.config/retroarch/retroarch.cfg"
RACORECONF="/storage/.config/retroarch/retroarch-core-options.cfg"
PLATFORM=${1,,}
CORE=${3,,}
ROM="${2##*/}"
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

#Self language retroarch
LANGEMUELEC=$(get_ee_setting system.language)

if [ "$LANGEMUELEC" == "pt_BR" ] || [ "$LANGEMUELEC" == "pt_PT" ]; then
    LANGEMUELEC="7"
elif [ "$LANGEMUELEC" == "en_US" ] || [ "$LANGEMUELEC" == "en_GB" ]; then
    LANGEMUELEC="0"
elif [ "$LANGEMUELEC" == "fr_FR" ]; then
    LANGEMUELEC="2"
elif [ "$LANGEMUELEC" == "es_ES" ] || [ "$LANGEMUELEC" == "es_MX" ]; then
    LANGEMUELEC="3"
elif [ "$LANGEMUELEC" == "de_DE" ]; then
    LANGEMUELEC="4"
elif [ "$LANGEMUELEC" == "it_IT" ]; then
    LANGEMUELEC="5"
elif [ "$LANGEMUELEC" == "eu_ES" ]; then
    LANGEMUELEC="21"
elif [ "$LANGEMUELEC" == "tr_TR" ]; then
    LANGEMUELEC="17"
elif [ "$LANGEMUELEC" == "zh_CN" ]; then
    LANGEMUELEC="11"
elif [ "$LANGEMUELEC" == "zh_TW" ]; then
    LANGEMUELEC="12"
elif [ "$LANGEMUELEC" == "ko_KR" ]; then
    LANGEMUELEC="8"
elif [ "$LANGEMUELEC" == "ja_JP" ]; then
    LANGEMUELEC="9"
elif [ "$LANGEMUELEC" == "ru_RU" ]; then
    LANGEMUELEC="14"
elif [ "$LANGEMUELEC" == "nl_NL" ]; then
    LANGEMUELEC="10"
elif [ "$LANGEMUELEC" == "pl_PL" ]; then
    LANGEMUELEC="15"
elif [ "$LANGEMUELEC" == "sv_SE" ]; then
    LANGEMUELEC="16"
elif [ "$LANGEMUELEC" == "hu_HU" ]; then
    LANGEMUELEC="19"
elif [ "$LANGEMUELEC" == "cs_CZ" ]; then
    LANGEMUELEC="20"
else
    LANGEMUELEC="0"
fi

sed -i "s/user_language = \"[^\"]*\"/user_language = \"$LANGEMUELEC\"/" ${RACONF}

# For the new snapshot save state manager we need to set the path to be /storage/roms/savestates/[PLATFORM]
mkdir -p "/storage/roms/savestates/${PLATFORM}"
sed -i '/savestates_in_content_dir =/d' ${RACONF}
sed -i '/sort_savefiles_by_content_enable =/d' ${RACONF}
sed -i '/sort_savefiles_enable =/d' ${RACONF}
sed -i '/sort_savestates_by_content_enable =/d' ${RACONF}
sed -i '/sort_savestates_enable =/d' ${RACONF}
sed -i '/savestate_directory =/d' ${RACONF}
echo 'savestates_in_content_dir = "false"' >> ${RACONF}
echo 'sort_savefiles_by_content_enable = false"' >> ${RACONF}
echo 'sort_savefiles_enable = "false"' >> ${RACONF}
echo 'sort_savestates_by_content_enable = "false"' >> ${RACONF}
echo 'sort_savestates_enable = "false"' >> ${RACONF}


echo "savestate_directory = \"/storage/roms/savestates/${PLATFORM}\"" >> ${RACONF}


function clean_settings() {
# IMPORTANT: Every setting we change should be removed from retroarch.cfg before we do any changes.
    sed -i '/video_scale_integer =/d' ${RACONF}
    sed -i '/video_scale_integer_overscale =/d' ${RACONF}
    sed -i '/video_shader =/d' ${RACONF}
    sed -i '/video_shader_enable =/d' ${RACONF}
    sed -i '/video_smooth =/d' ${RACONF}
    sed -i '/aspect_ratio_index =/d' ${RACONF}
    sed -i '/rewind_enable =/d' ${RACONF}
    sed -i '/run_ahead_enabled =/d' ${RACONF}
    sed -i '/run_ahead_frames =/d' ${RACONF}
    sed -i '/run_ahead_secondary_instance =/d' ${RACONF}
    sed -i '/savestate_auto_save =/d' ${RACONF}
    sed -i '/savestate_auto_load =/d' ${RACONF}
    sed -i '/cheevos_enable =/d' ${RACONF}
    sed -i '/cheevos_username =/d' ${RACONF}
    sed -i '/cheevos_password =/d' ${RACONF}
    sed -i '/cheevos_hardcore_mode_enable =/d' ${RACONF}
    sed -i '/cheevos_start_active =/d' ${RACONF}
    sed -i '/cheevos_leaderboards_enable =/d' ${RACONF}
    sed -i '/cheevos_verbose_enable =/d' ${RACONF}
    sed -i '/cheevos_auto_screenshot =/d' ${RACONF}
    sed -i '/ai_service_mode =/d' ${RACONF}
    sed -i '/ai_service_enable =/d' ${RACONF}
    sed -i '/ai_service_source_lang =/d' ${RACONF}
    sed -i '/ai_service_url =/d' ${RACONF}
    sed -i "/input_libretro_device_p1/d" ${RACONF}
    sed -i "/fps_show/d" ${RACONF}
    sed -i "/netplay =/d" ${RACONF}
    sed -i "/netplay_ip_port/d" ${RACONF}
    sed -i "/netplay_delay_frames/d" ${RACONF}
    sed -i "/netplay_nickname/d" ${RACONF}
    sed -i "/netplay_client_swap_input/d" ${RACONF}
    sed -i "/netplay_ip_port/d" ${RACONF}
    sed -i "/netplay_server_ip/d" ${RACONF}
    sed -i "/netplay_client_swap_input/d" ${RACONF}
    sed -i "/netplay_spectator_mode_enable/d" ${RACONF}
    sed -i "/netplay_use_mitm_server =/d" ${RACONF}
    sed -i "/netplay_ip_address/d" ${RACONF}
    sed -i "/netplay_mitm_server/d" ${RACONF}
    sed -i "/netplay_mode/d" ${RACONF}
    sed -i '/netplay_spectate_password =/d' ${RACONF}
    sed -i '/netplay_password =/d' ${RACONF}
    sed -i '/netplay_public_announce =/d' ${RACONF}
    sed -i '/netplay_start_as_spectator =/d' ${RACONF}
    sed -i "/video_oga_vertical_enable/d" ${RACONF}
    sed -i "/video_ogs_vertical_enable/d" ${RACONF}
    sed -i '/video_ctx_scaling =/d' ${RACONF}
    sed -i '/video_frame_delay_auto =/d' ${RACONF}
}

function default_settings() {
# IMPORTANT: Every setting we change should have a default value here
    clean_settings
    echo 'video_scale_integer = "false"' >> ${RACONF}
    echo 'video_scale_integer_overscale = "false"' >> ${RACONF}
    echo 'video_shader = ""' >> ${RACONF}
    echo 'video_shader_enable = "false"' >> ${RACONF}
    echo 'video_smooth = "false"' >> ${RACONF}
    echo 'aspect_ratio_index = "22"' >> ${RACONF}
    echo 'rewind_enable = "false"' >> ${RACONF}
    echo 'run_ahead_enabled = "false"' >> ${RACONF}
    echo 'run_ahead_frames = "1"' >> ${RACONF}
    echo 'run_ahead_secondary_instance = "false"' >> ${RACONF}
    echo 'savestate_auto_save = "false"' >> ${RACONF}
    echo 'savestate_auto_load = "false"' >> ${RACONF}
    echo 'cheevos_enable = "false"' >> ${RACONF}
    echo 'cheevos_username = ""' >> ${RACONF}
    echo 'cheevos_password = ""' >> ${RACONF}
    echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}
    echo 'cheevos_start_active = "false"' >> ${RACONF}
    echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}
    echo 'cheevos_verbose_enable = "false"' >> ${RACONF}
    echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
    echo 'ai_service_mode = "0"' >> ${RACONF}
    echo 'ai_service_enable = false' >> ${RACONF}
    echo 'ai_service_source_lang = "0"' >> ${RACONF}
    echo 'ai_service_url = ""' >> ${RACONF}
    echo "input_libretro_device_p1 = \"1\"" >> ${RACONF}
    echo 'fps_show = false' >> ${RACONF}
    echo 'netplay = false' >> ${RACONF}
    echo 'video_oga_vertical_enable = "false"' >> ${RACONF}
    echo 'video_ogs_vertical_enable = "false"' >> ${RACONF}
    echo 'video_ctx_scaling = "false"' >> ${RACONF}
    echo 'video_frame_delay_auto = "false"' >> ${RACONF}
}

function set_setting() {
# we set the setting on the configuration file
case ${1} in
    "ratio")
    if [[ "${2}" == "false" ]]; then
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
        [ "${2}" == "1" ] && echo 'video_smooth = "true"' >> ${RACONF} || echo 'video_smooth = "false"' >> ${RACONF}
    ;;
    "rewind")
        (for e in "${NOREWIND[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RE=0 || RE=1
            if [ ${RE} == 1 ] && [ "${2}" == "1" ]; then
                echo 'rewind_enable = "true"' >> ${RACONF}
            else
                echo 'rewind_enable = "false"' >> ${RACONF}
            fi
    ;;
    "autosave")
        if [ "${AUTOSAVE}" == "0" ]; then
            echo 'savestate_auto_save = "false"' >> ${RACONF}
            echo 'savestate_auto_load = "false"' >> ${RACONF}
        else
            echo 'savestate_auto_save = "true"' >> ${RACONF}
            echo 'savestate_auto_load = "true"' >> ${RACONF}
            AUTOLOAD="true"
        fi
    ;;
    "snapshot")

        sed -i "/state_slot =/d" ${RACONF}

        if [[ ! -z ${SNAPSHOT} ]]; then
            echo "state_slot = \"${SNAPSHOT}\"" >> ${RACONF}
        else
            if [[ ${AUTOLOAD} == "false" ]]; then
                sed -i "/savestate_auto_load =/d" ${RACONF}
                sed -i "/savestate_auto_save =/d" ${RACONF}

                echo 'savestate_auto_save = "false"' >> ${RACONF}
                echo 'savestate_auto_load = "false"' >> ${RACONF}
            fi
            echo 'state_slot = "0"' >> ${RACONF}
        fi
    ;;
    "integerscale")
        [ "${2}" == "1" ] && echo 'video_scale_integer = "true"' >> ${RACONF} || echo 'video_scale_integer = "false"' >> ${RACONF}
        [ "${2}" == "1" ] && ISBEZEL="true" || ISBEZEL="false"
    ;;
    "integerscaleoverscale")
        [ "${2}" == "1" ] && echo 'video_scale_integer_overscale = "true"' >> ${RACONF} || echo 'video_scale_integer_overscale = "false"' >> ${RACONF}
    ;;
    "rgascale")
                [ "${2}" == "1" ] && echo 'video_ctx_scaling = "true"' >> ${RACONF} || echo 'video_ctx_scaling = "false"' >> ${RACONF}
        ;;
    "shaderset")
        if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then
            echo 'video_shader_enable = "false"' >> ${RACONF}
            echo 'video_shader = ""' >> ${RACONF}
        else
            echo "video_shader = \"${2}\"" >> ${RACONF}
            echo 'video_shader_enable = "true"' >> ${RACONF}
            echo "--set-shader /tmp/shaders/${2}"
        fi
    ;;
    "runahead")
    (for e in "${NORUNAHEAD[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RA=0 || RA=1
    if [ ${RA} == 1 ]; then
        if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then
            echo 'run_ahead_enabled = "false"' >> ${RACONF}
            echo 'run_ahead_frames = "1"' >> ${RACONF}
        else
            echo 'run_ahead_enabled = "true"' >> ${RACONF}
            echo "run_ahead_frames = \"${2}\"" >> ${RACONF}
        fi
    fi
    ;;
    "secondinstance")
    (for e in "${NORUNAHEAD[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RA=0 || RA=1
    if [ ${RA} == 1 ]; then
        [ "${2}" == "1" ] && echo 'run_ahead_secondary_instance = "true"' >> ${RACONF} || echo 'run_ahead_secondary_instance = "false"' >> ${RACONF}
    fi
    ;;
    "video_frame_delay_auto")
                [ "${2}" == "1" ] && echo 'video_frame_delay_auto = "true"' >> ${RACONF} || echo 'video_frame_delay_auto = "false"' >> ${RACONF}
        ;;
    "ai_service_enabled")
        if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then
            echo 'ai_service_enable = "false"' >> ${RACONF}
        else
            echo 'ai_service_enable = "true"' >> ${RACONF}
            get_setting "ai_target_lang"
            AI_LANG=${EES}
            [[ "${AI_LANG}" == "false" ]] && ${AI_LANG}="0"
            get_setting "ai_service_url"
            AI_URL=${EES}
            echo "ai_service_source_lang = \"${AI_LANG}\"" >> ${RACONF}
            if [ "${AI_URL}" == "false" ] || [ "${AI_URL}" == "auto" ] || [ "${AI_URL}" == "none" ]; then
                echo "ai_service_url = \"http://ztranslate.net/service?api_key=BATOCERA&mode=Fast&output=png&target_lang=\"${AI_LANG}\"" >> ${RACONF}
            else
                echo "ai_service_url = \"${AI_URL}&mode=Fast&output=png&target_lang=\"${AI_LANG}\"" >> ${RACONF}
            fi
        fi
    ;;
    "retroachievements")
        for i in "${!RETROARCHIVEMENTS[@]}"; do
            if [[ "${RETROARCHIVEMENTS[${i}]}" = "${PLATFORM}" ]]; then
                if [ "${2}" == "1" ]; then
                    echo 'cheevos_enable = "true"' >> ${RACONF}
                    get_setting "retroachievements.username"
                    echo "cheevos_username = \"${EES}\""  >> ${RACONF}
                    get_setting "retroachievements.password"
                    echo "cheevos_password = \"${EES}\""  >> ${RACONF}

                    # retroachievements_hardcore_mode
                    get_setting "retroachievements.hardcore"
                    [ "${EES}" == "1" ] && echo 'cheevos_hardcore_mode_enable = "true"' >> ${RACONF} || echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}

                    # retroachievements_encore_mode
                    get_setting "retroachievements.encore"
                    [ "${EES}" == "1" ] && echo 'cheevos_start_active = "true"' >> ${RACONF} || echo 'cheevos_start_active = "false"' >> ${RACONF}

                    # retroachievements_leaderboards
                    get_setting "retroachievements.leaderboards"
                    [ "${EES}" == "1" ] && echo 'cheevos_leaderboards_enable = "true"' >> ${RACONF} || echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}

                    # retroachievements_verbose_mode
                    get_setting "retroachievements.verbose"
                    [ "${EES}" == "1" ] && echo 'cheevos_verbose_enable = "true"' >> ${RACONF} || echo 'cheevos_verbose_enable = "false"' >> ${RACONF}

                    # retroachievements_automatic_screenshot
                    get_setting "retroachievements.screenshot"
                    [ "${EES}" == "1" ] && echo 'cheevos_auto_screenshot = "true"' >> ${RACONF} || echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
                else
                    echo 'cheevos_enable = "false"' >> ${RACONF}
                    echo 'cheevos_username = ""' >> ${RACONF}
                    echo 'cheevos_password = ""' >> ${RACONF}
                    echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}
                    echo 'cheevos_start_active = "false"' >> ${RACONF}
                    echo 'cheevos_leaderboards_enable = "false"' >> ${RACONF}
                    echo 'cheevos_verbose_enable = "false"' >> ${RACONF}
                    echo 'cheevos_auto_screenshot = "false"' >> ${RACONF}
                fi
            fi
        done
    ;;
    "netplay")

    if [ "${2}" == "false" ] || [ "${2}" == "none" ] || [ "${2}" == "0" ]; then
            echo 'netplay = false' >> ${RACONF}
    else
        echo 'netplay = true' >> ${RACONF}

        get_setting "netplay.mode"
        NETPLAY_MODE=${EES}

        # Security : hardcore mode disables save states, which would kill netplay
        sed -i '/cheevos_hardcore_mode_enable =/d' ${RACONF}
        echo 'cheevos_hardcore_mode_enable = "false"' >> ${RACONF}

    if [[ "${NETPLAY_MODE}" == "host" ]]; then
        # Quite strangely, host mode requires netplay_mode to be set to false when launched from command line
        echo 'netplay_mode = false' >> ${RACONF}
        echo 'netplay_client_swap_input = false' >> ${RACONF}
        get_setting "netplay.port"
        echo "netplay_ip_port = ${EES}" >> ${RACONF}

    elif [[ "${NETPLAY_MODE}" == "client" || "${NETPLAY_MODE}" == "spectator" ]]; then
        # But client needs netplay_mode = true ... bug ?
        echo 'netplay_mode = true' >> ${RACONF}

        get_setting "netplay.server.ip"
        sed -i  "s|netplay_ip_address =.*|netplay_ip_address = ${EES}|" ${RACONF}

        get_setting "netplay.server.port"
        sed -i  "s|netplay_ip_port =.*|netplay_ip_port = ${EES}|" ${RACONF}

        echo 'netplay_client_swap_input = true' >> ${RACONF}

    fi # Host or Client

    if [[ "${NETPLAY_MODE}" == "spectator" ]]; then
        echo 'netplay_start_as_spectator = true' >> ${RACONF}
    fi

        get_setting "netplay.password"
        if [[ ! -z "${EES}" && "${EES}" != "none" && "${EES}" != "false" ]]; then
         echo "netplay_password = \"${EES}\"" >> ${RACONF}
        else
         sed -i '/netplay_password =/d' ${RACONF}
        fi

        get_setting "netplay.spectatepassword"
        if [[ ! -z "${EES}" && "${EES}" != "none" && "${EES}" != "false" ]]; then
         echo "netplay_spectate_password = \"${EES}\"" >> ${RACONF}
        else
         sed -i '/netplay_spectate_password =/d' ${RACONF}
        fi

        # Netplay hide the gameplay
        get_setting "netplay_public_announce"
        if [[ ! -z "${EES}" && "${EES}" != "none" && "${EES}" != "false" ]]; then
           echo "netplay_public_announce = true" >> ${RACONF}
        else
           echo "netplay_public_announce = false" >> ${RACONF}
        fi

        # relay
        get_setting "netplay.relay"
        if [[ ! -z "${EES}" && "${EES}" != "none" && "${EES}" != "false" ]]; then
            echo 'netplay_use_mitm_server = true'  >> ${RACONF}
            echo "netplay_mitm_server = ${EES}" >> ${RACONF}
        else
            echo 'netplay_use_mitm_server = false' >> ${RACONF}
            sed -i "/netplay_mitm_server/d" ${RACONF}
        fi

        get_setting "netplay.frames"
        echo "netplay_delay_frames = ${EES}" >> ${RACONF}

        get_setting "netplay.nickname"
        echo "netplay_nickname = ${EES}" >> ${RACONF}

    # mode spectator
       #  get_setting "netplay.spectator"
       #  [ "${EES}" == "1" ] && echo 'netplay_spectator_mode_enable = true' >> ${RACONF} || echo 'netplay_spectator_mode_enable = false' >> ${RACONF}

    fi
    ;;
    "fps")
    # Display FPS
    get_setting "showFPS"
    [ "${EES}" == "1" ] && echo 'fps_show = "true"' >> ${RACONF} || echo 'fps_show = "false"' >> ${RACONF}
    ;;
    "vertical")
    # Vertical orientation game
    if [ "${EES}" == "1" ]; then
        echo 'video_oga_vertical_enable = "true"' >> ${RACONF}
        sed -i "/aspect_ratio_index/d" ${RACONF}

        get_setting "vert_aspect"

    if [ "${EES}" == "false" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ] || [ "${EES}" == "1" ]; then
        echo 'aspect_ratio_index = "1"' >> ${RACONF}
        IRBEZEL="1"
    else
        echo "aspect_ratio_index = \"${EES}\"" >> ${RACONF}
        IRBEZEL="${EES}"
    fi
        case "$(oga_ver)" in
            "OGA")
                if [ -f "/tmp/joypads/GO-Advance Gamepad_vertical.cfg" ]; then
                    mv "/tmp/joypads/GO-Advance Gamepad.cfg" "/tmp/joypads/GO-Advance Gamepad_horizontal.cfg"
                    mv "/tmp/joypads/GO-Advance Gamepad_vertical.cfg" "/tmp/joypads/GO-Advance Gamepad.cfg"
                fi
            ;;
            "OGABE")
                if [ -f "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg" ]; then
                    mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_horizontal.cfg"
                    mv "/tmp/joypads/GO-Advance Gamepad (rev 1.1)_vertical.cfg" "/tmp/joypads/GO-Advance Gamepad (rev 1.1).cfg"
                fi
            ;;
            "OGS")
                echo 'video_ogs_vertical_enable = "true"' >> ${RACONF}
                if [ -f "/tmp/joypads/GO-Super Gamepad_vertical.cfg" ]; then
                    mv "/tmp/joypads/GO-Super Gamepad.cfg" "/tmp/joypads/GO-Super Gamepad_horizontal.cfg"
                    mv "/tmp/joypads/GO-Super Gamepad_vertical.cfg" "/tmp/joypads/GO-Super Gamepad.cfg"
                fi
            ;;
        esac
    else
        echo 'video_oga_vertical_enable = "false"' >> ${RACONF}
        echo 'video_ogs_vertical_enable = "false"' >> ${RACONF}

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
    ;;
esac
}

function get_setting() {
#We look for the setting on the ROM first, if not found we search for platform and lastly we search globally
    PAT="s|^${PLATFORM}\[\"${ROM}\"\].*${1}=\(.*\)|\1|p"
    EES=$(sed -n "${PAT}" "${CONF}")

if [ -z "${EES}" ]; then
    PAT="s|^${PLATFORM}[\.-]${1}=\(.*\)|\1|p"
    EES=$(sed -n "${PAT}" "${CONF}")
fi

if [ -z "${EES}" ]; then
    PAT="s|^global[\.-].*${1}=\(.*\)|\1|p"
    EES=$(sed -n "${PAT}" "${CONF}")
fi

# Sanity check in case there there are 2 variables set, only use the first line
EES=$(echo ${EES} | head -1)

[ -z "${EES}" ] && EES="false"
set_setting ${1} ${EES}
}

clean_settings

for s in ratio smooth shaderset rewind autosave integerscale integerscaleoverscale runahead secondinstance video_frame_delay_auto retroachievements ai_service_enabled netplay fps vertical rgascale snapshot; do
get_setting ${s}
[ -z "${EES}" ] || SETF=1
done

if [ ${SETF} == 0 ]; then
# If no setting was changed, set all options to default on the configuration files
default_settings
fi

if [ "${CORE}" == "atari800" ]; then
ATARICONF="/storage/.config/emuelec/configs/atari800.cfg"
ATARI800CONF="/storage/.config/retroarch/config/Atari800/Atari800.opt"
[[ ! -f "${ATARI800CONF}" ]] && touch "${ATARI800CONF}"

sed -i "/atari800_system =/d" ${RACORECONF}
sed -i "/RAM_SIZE=/d" ${ATARICONF}
sed -i "/STEREO_POKEY=/d" ${ATARICONF}
sed -i "/BUILTIN_BASIC=/d" ${ATARICONF}
sed -i "/atari800_system =/d" ${ATARI800CONF}

    if [ "${PLATFORM}" == "atari5200" ]; then
            echo "atari800_system = \"5200\"" >> ${RACORECONF}
            echo "atari800_system = \"5200\"" >> ${ATARI800CONF}
            echo "RAM_SIZE=16" >> ${ATARICONF}
            echo "STEREO_POKEY=0" >> ${ATARICONF}
            echo "BUILTIN_BASIC=0" >> ${ATARICONF}
    else
            echo "atari800_system = \"800XL (64K)\"" >> ${RACORECONF}
            echo "atari800_system = \"800XL (64K)\"" >> ${ATARI800CONF}
            echo "RAM_SIZE=64" >> ${ATARICONF}
            echo "STEREO_POKEY=1" >> ${ATARICONF}
            echo "BUILTIN_BASIC=1" >> ${ATARICONF}
     fi
fi

if [ "${PLATFORM}" == "amstradgx4000" ]; then
# Make sure cap32_model is set to "6128+"
GX4000CONF="/storage/.config/retroarch/config/cap32/cap32.opt"
[[ ! -f "${GX4000CONF}" ]] && touch "${GX4000CONF}"
    sed -i "/cap32_model =/d" "${GX4000CONF}"
    echo "cap32_model = \"6128+\"" >> "${GX4000CONF}"
fi

if [ "${CORE}" == "gambatte" ]; then
GAMBATTECONF="/storage/.config/retroarch/config/Gambatte/Gambatte.opt"
[[ ! -f "${GAMBATTECONF}" ]] && touch "${GAMBATTECONF}"

sed -i "/gambatte_gb_colorization =/d" ${RACORECONF}
sed -i "/gambatte_gb_internal_palette =/d" ${RACORECONF}
sed -i "/gambatte_gb_colorization =/d" ${GAMBATTECONF}
sed -i "/gambatte_gb_internal_palette =/d" ${GAMBATTECONF}

        get_setting "renderer.colorization"
        if [ "${EES}" == "false" ] || [ "${EES}" == "auto" ] || [ "${EES}" == "none" ]; then
            echo "gambatte_gb_colorization = \"disabled\"" >> ${RACORECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${RACORECONF}
            echo "gambatte_gb_colorization = \"disabled\"" >> ${GAMBATTECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${GAMBATTECONF}
        elif [ "${EES}" == "GBC" ]; then
            echo "gambatte_gb_colorization = \"GBC\"" >> ${RACORECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${RACORECONF}
            echo "gambatte_gb_colorization = \"GBC\"" >> ${GAMBATTECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${GAMBATTECONF}
        elif [ "${EES}" == "SGB" ]; then
            echo "gambatte_gb_colorization = \"SGB\"" >> ${RACORECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${RACORECONF}
            echo "gambatte_gb_colorization = \"SGB\"" >> ${GAMBATTECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${GAMBATTECONF}
        elif [ "${EES}" == "Best Guess" ]; then
            echo "gambatte_gb_colorization = \"auto\"" >> ${RACORECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${RACORECONF}
            echo "gambatte_gb_colorization = \"auto\"" >> ${GAMBATTECONF}
            echo "gambatte_gb_internal_palette = \"\"" >> ${GAMBATTECONF}
        else
            echo "gambatte_gb_colorization = \"internal\"" >> ${RACORECONF}
            echo "gambatte_gb_internal_palette = \"${EES}\"" >> ${RACORECONF}
            echo "gambatte_gb_colorization = \"internal\"" >> ${GAMBATTECONF}
            echo "gambatte_gb_internal_palette = \"${EES}\"" >> ${GAMBATTECONF}
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
sed -i "/input_player${i}_joypad_index =/d" ${RACONF}
echo "input_player${i}_joypad_index = \"${PINDEX}\"" >> ${RACONF}

# Setting controller type for different cores
if [ "${PLATFORM}" == "atari5200" ]; then
    sed -i "/input_libretro_device_p${i}/d" ${RACONF}
    echo "input_libretro_device_p${i} = \"513\"" >> ${RACONF}
fi

fi
done
EE_DEVICE=$(cat /ee_arch)
get_setting "retroarch.menu_driver"

if [ "${EES}" == "false" ] || [ "${EES}" == "auto" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ]; then
    if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
        EES="xmb"
    else
        EES="ozone"
    fi
fi

sed -i "/menu_driver =/d" ${RACONF}
echo "menu_driver = ${EES}" >> ${RACONF}

# Show bezel if enabled
get_setting "bezel"
[ "${EES}" == "false" ] || [ "${EES}" == "none" ] || [ "${EES}" == "0" ] && ${TBASH} bezels.sh "none" "default" "${ISBEZEL}" "${IRBEZEL}" || ${TBASH} bezels.sh "${PLATFORM}" "${ROM}" "${ISBEZEL}" "${IRBEZEL}"
