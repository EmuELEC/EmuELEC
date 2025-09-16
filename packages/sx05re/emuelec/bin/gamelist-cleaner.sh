#!/bin/bash - 
# gamelist-cleaner.sh
#####################
#
# This script gets a gamelist.xml as input and check if the path for the games
# leads to an existing file. If the file doesn't exist, the <game> entry will
# be deleted from the resulting gamelist.xml.
#
# Run the script with '--help' to get more info.
# 
# meleu - 2017/Jun
# kaltinril - 2017-08-19 - Added -r option to replace the existing gameslist
# shantigilbert - 2019-02-18 - Fix for filenames with '&' not being removed

# Global Variables
REPLACE_GAMELIST=false
DO_ALL=false
LISTS_DIR="${HOME}/.emulationstation/gamelists"
ROMS_DIR="${HOME}/roms"
ELIMINATE_BACKUPS=false

# Read only Variables
readonly SCRIPT_DIR="$(dirname "${0}")"
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_FULL="${SCRIPT_DIR}/${SCRIPT_NAME}"
readonly SCRIPT_URL="https://raw.githubusercontent.com/meleu/share/master/gamelist-cleaner.sh"

readonly USAGE="Usage:
${0} [OPTIONS] [gamelist.xml]...
"

readonly EXAMPLE="Example:
${0} ~/.emulationstation/gamelists/nes/gamelist.xml
"

readonly HELP="
This script gets a gamelist.xml as input and checks if the path for the games
leads to an existing file. If the file doesn't exist, the <game> entry will
be deleted and a cleaner gamelist.xml file will be generated.

The resulting file will be named \"gamelist.xml-clean\" and will be in the
same folder as the original file. Nothing changes in the original gamelist.xml.

${USAGE}
${EXAMPLE}
The OPTIONS are:

-h|--help           print this message and exit.

-u|--update         update the script and exit.

-s|--system SYSTEM  specifies to which system the gamelist.xml file belongs,
                    e.g.: nes, megadrive. Default: name of the directory where
                    the file is located.

-d|--directory DIR  specifies the ROMs directory. Default:
                    ${ROMS_DIR}

-r|--replace        Force replace the gamelist.xml file (Creates backup of original)

-a|--all            Automatically clean all gamelists that exist in lists folder

-l|--gamelist DIR   specifies the gamelist directory.  Default:
                    ${LISTS_DIR}
"

function update_script() {
    local err_flag=0
    local err_msg

    if err_msg=$(wget "${SCRIPT_URL}" -O "/tmp/${SCRIPT_NAME}" 2>&1); then
        if diff -q "${SCRIPT_FULL}" "/tmp/${SCRIPT_NAME}" >/dev/null; then
            echo "You already have the latest version. Nothing changed."
            rm -f "/tmp/${SCRIPT_NAME}"
            exit 0
        fi
        err_msg=$(mv "/tmp/${SCRIPT_NAME}" "${SCRIPT_FULL}" 2>&1) \
        || err_flag=1
    else
        err_flag=1
    fi

    if [[ ${err_flag} -ne 0 ]]; then
        err_msg=$(echo "${err_msg}" | tail -1)
        echo "Failed to update \"${SCRIPT_NAME}\": ${err_msg}" >&2
        exit 1
    fi
    
    chmod a+x "${SCRIPT_FULL}"
    echo "The script has been successfully updated. You can run it again."
    exit 0
}

function eliminate_backup_files() {
    backups=$(ls ${LISTS_DIR}/*/gamelist.xml-orig*)
    for file in ${backups}; do
      echo "Removing: ${file}"
      rm ${file}
    done
}

while [[ -n "${1}" ]]; do
    case "${1}" in
        -h|--help)
            echo "${HELP}" >&2
            exit 0
            ;;
        -u|--update)
            update_script
            ;;
        -s|--system)
            shift
            CUSTOM_SYSTEM="${1}"
            shift
            ;;
        -d|--directory)
            shift
            ROMS_DIR="${1}"
            shift
            ;;
        -r|--replace)
            shift
            REPLACE_GAMELIST=true
            echo "Using replace option"
            echo
            ;;
        -a|--all)
            shift
            DO_ALL=true
            echo "Cleaning all gamelists!"
            echo
            ;;
        -l|--list)
            shift
            LISTS_DIR="${1}"
            shift
            ;;
        -e|--eliminate)
            shift
            ELIMINATE_BACKUPS=true
            echo "Using eliminate option"
            echo
            ;;
        '')
            echo "ERROR: missing gamelist.xml parameter" >&2
            echo "${HELP}" >&2
            exit 1
            ;;
        -*) # yes, files starting with '-' don't work in this script
            echo "ERROR: \"${1}\": invalid option" >&2
            echo "${HELP}" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Verify there is at least 1 file after all parameters
if [ "$#" -eq 0 ] && [ "${DO_ALL}" = false ]; then
    echo "ERROR: missing gamelist.xml parameter" >&2
    echo "${HELP}" >&2
    exit 1
fi

# Get list of files to use
gamelist_files="$@"
if [ "${DO_ALL}" = true ]; then
    gamelist_files=$(ls ${LISTS_DIR}/*/gamelist.xml)
fi

for file in ${gamelist_files}; do
    original_gamelist="$(readlink -f "${file}")"
    clean_gamelist="${original_gamelist}-clean"
    gamelist_dir="$(dirname "${original_gamelist}")"
    backup_gamelist="${original_gamelist}-orig-$(date +%s)"

    if [[ ! -s "${original_gamelist}" ]]; then
        [[ -z "${original_gamelist}" ]] && original_gamelist="${file}" # Make sure we print the name if the readlink failed to find a file
        echo "\"${original_gamelist}\": file not found or is zero-length. Ignoring..."
        continue
    fi

    system="${CUSTOM_SYSTEM}"
    [[ -z "${system}" ]] && system=$(basename "${gamelist_dir}")
    if [[ ! -d "${ROMS_DIR}/${system}" ]]; then
        echo "WARNING: \"${ROMS_DIR}/${system}\": directory not found." >&2
        echo "You don't have a ROMs folder for a system named \"${system}\"." >&2
        echo "Ignoring \"${original_gamelist}\"..." >&2
        continue
    fi

    # What file are we working on?
    echo "Working on: ${original_gamelist}"
    
    # Make backup of gamelist and replace original
    if [ "${REPLACE_GAMELIST}" = true ]; then
      cat "${original_gamelist}" > "${backup_gamelist}"
      clean_gamelist="${original_gamelist}"
      original_gamelist="${backup_gamelist}"
    fi
    
    # use a temp file to convert "&" to "&amp: on the whole gamelist.xml even if the file has both "&" and "&amp;"
    temp_gamelist="/tmp/gamelist-${system}.xml"
    sed "s/\&/&amp;/g; s/;amp;/;/g; s/&amp;#39;/'/g" "${original_gamelist}" > "${temp_gamelist}"
    original_gamelist=$(readlink -f "${temp_gamelist}")
    cat "${original_gamelist}" > "${clean_gamelist}"

    # Check to see if we have any entries before we try to loop over them.
    xml_entries=$(xmlstarlet sel -t -v "/gameList/game/path" "${original_gamelist}")
    if [[ -z ${xml_entries} ]]; then
        echo "No entries found, file is empty."
        echo
        echo
        continue
    fi
    
    while read -r path; do
        #it seems xmlstarlet will convert '&amp;' internally, so remove it from the path or else the node will not be found
        path="${path//&amp;/&}"
        full_path="${path}"
        [[ "${path}" == ./* ]] && full_path="${ROMS_DIR}/${system}/${path}"
        [[ -f "${full_path}" ]] && continue

        xmlstarlet ed -L -d "/gameList/game[path=\"${path}\"]" "${clean_gamelist}"
        echo "The game with <path> = \"${path}\" has been removed from xml."
    done < <(xmlstarlet sel -t -v "/gameList/game/path" "${original_gamelist}"; echo)
    echo
    echo "The \"${clean_gamelist}\" is ready!"
    echo
    echo "See the difference between file sizes:"
    du -h "${original_gamelist}" "${clean_gamelist}"
    rm "${temp_gamelist}"
    echo
    echo
done

if [ "${ELIMINATE_BACKUPS}" = true ];then
    echo "Removing backups...."
    eliminate_backup_files
fi
