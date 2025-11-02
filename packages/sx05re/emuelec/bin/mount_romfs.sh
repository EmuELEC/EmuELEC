#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

# Source predefined functions and variables
. /etc/profile

ROMS_PART_LABEL='EEROMS'
ROMS_PART_FS_CONFIG='/flash/ee_fstype'
ROMS_FILE_MARK='emuelecroms'
ROMS_DIR_NAME='roms'
ROMS_DIR_ACTUAL="/storage/${ROMS_DIR_NAME}"
UPDATE_DIR='/storage/.update'
ROMS_DIR_BACKUP="${ROMS_DIR_ACTUAL}_backup"
MEDIA_DIR='/var/media'
ROMS_DIR_MEDIA="${MEDIA_DIR}/${ROMS_PART_LABEL}"

if [ "${1}" == 'yes' ]; then
  ACTION_ES_RESTART='yes'
  echo 'Note: restart of EmulattionStation is requested, it will be restarted after roms is correctly mounted'
else
  ACTION_ES_RESTART=''
fi

if [ "${2}" ]; then
  ROMS_PART_MATCHER="${2}"
else
  ROMS_PART_MATCHER="$(get_ee_setting global.externalmount)"
  if [[ "${ROMS_PART_MATCHER}" == 'auto' || -z "${ROMS_PART_MATCHER}" ]]; then
    echo 'Note: no specific externalmount defined in config or argument, will try to scan all possible external drives'
    ROMS_PART_MATCHER='*'
  fi
fi

get_mount_list() {  # MOUNTPOINT should be set/gotten by outer functions
  local IFS=$'\n'
  MOUNTLIST=($(printf "$(cat /proc/mounts | cut -d ' ' -f 2)")) # Use printf to convert \040, \134, etc back to ' ', '\', etc
}

umount_recursively() { # ${1}: start point, e.g. /storage. This is a replica of umount -r from standard Linux distros
  [ -z "${1}" ] && return 1
  local TARGET="$(readlink -f "${1}")"
  [ -z "${TARGET}" ] && TARGET="$(pwd -P)/${1}"
  echo "WARNING: unmounting '${TARGET}', recursively"
  local IFS=$'\n'
  UMOUNTLIST=($(printf "$(cat /proc/mounts | cut -d ' ' -f 2)" | grep ^"${TARGET}"'\(/\|$\)' | sort -r ))
  unset IFS
  local MOUNTPOINT
  local TRY
  for MOUNTPOINT in "${UMOUNTLIST[@]}"; do
    for TRY in {0..2}; do # Brute force, hope we only run once
      sync
      if umount -f "${MOUNTPOINT}"; then
        echo "Successfully umounted '${MOUNTPOINT}'"
        break
      fi
      sleep 1
    done
  done
}

move_merge() { #${1} source dir, ${2} target dir
  # e.g. move_merge /storage/roms_backup /storage/roms
  [ -z "${1}" ] || [ -z "${2}" ] && return 1
  local SOURCE="$(readlink -f "${1}")"
  local TARGET="$(readlink -f "${2}")"
  local PWD_SECURE="$(pwd -P)"
  [ -z "${SOURCE}" ] && SOURCE="${PWD_SECURE}/${1}"
  [ -z "${TARGET}" ] && TARGET="${PWD_SECURE}/${2}"
  echo "WARNING: Merging '${SOURCE}' into '${TARGET}'"
  pushd "${SOURCE}" &>/dev/null
  find . -type d -exec mkdir -p "${TARGET}/"\{} \; 
  find . -type f -exec mv \{} "${TARGET}/"\{} \; 
  find . -type d -empty -delete
  popd &>/dev/null
}

# Check if (multiple) EEROMS exists. By calling blkid we also force all drives to wake up
scan_eeroms() {
  BOOL_EEROMS_EXIST=''  # ='yes' if EEROMS exist, ='' if not
  ROMS_PART_PATH=''  # The dev path for the EEROMS partition, shouldn't be empty if EEROMS_EXIST
  ROMS_PART_TOKEN=''  # What we should use to mount eeroms, shouldn't be empty if EEROMS_EXIST, default is LABEL=EEROMS 
  # Get EEROMS filetype, vfat is default (considering capacity, it is most likely fat32)
  if [ -e "${ROMS_PART_FS_CONFIG}" ]; then
    ROMS_PART_FS="$(cat "${ROMS_PART_FS_CONFIG}")"
    case "${ROMS_PART_FS}" in
      'ntfs'|'ext4'|'exfat'|'vfat')
        : # Do nothing
      ;;
      *) # Always downgrade to vfat in case it's messed up
        ROMS_PART_FS="vfat"
      ;;
    esac 
  else
    ROMS_PART_FS='vfat'
  fi
  LINE_EEROMS="$(blkid | grep "LABEL=\"${ROMS_PART_LABEL}\"")" &>/dev/null
  if [ "${LINE_EEROMS}" ]; then
    ROMS_PART_FS_ACTUAL=''
    roms_part_fs_from_line(){
      ROMS_PART_FS_ACTUAL="$(sed -e 's/.* TYPE="\([a-z0-9]\+\)".*/\1/' <<< "${LINE_EEROMS}")"
    }
    if [ "$(wc -l <<< "${LINE_EEROMS}")" == 1 ]; then # Only one EEROMS, good
      ROMS_PART_PATH="${LINE_EEROMS%%:*}"
      roms_part_fs_from_line
    else # Multiple EEROMS
      LINES_EEROMS="${LINE_EEROMS}"
      while read LINE_EEROMS; do
        LINE_PART_PATH="${LINE_EEROMS%%:*}"
        if [ -z "${ROMS_PART_PATH}" ] || grep -q "^${LINE_PART_PATH} ${ROMS_DIR_ACTUAL} " '/proc/mounts'; then
          # At least use the first EEROMS. We prefer the one already mounted
          ROMS_PART_PATH="${LINE_PART_PATH}"
          roms_part_fs_from_line
        fi
      done <<< "${LINES_EEROMS}"
    fi
    if [ "${ROMS_PART_PATH}" ]; then
      ROMS_PART_TOKEN="${ROMS_PART_PATH}"
    else # Failsafe, this shouldn't happen
      ROMS_PART_TOKEN="LABEL=${ROMS_PART_LABEL}"
    fi
    case "${ROMS_PART_FS_ACTUAL}" in 
      # Update roms part fs in case it's different from the config
      'ntfs'|'ext4'|'exfat'|'vfat')
        if [ "${ROMS_PART_FS_ACTUAL}" != "${ROMS_PART_FS}" ]; then
          echo "WARNING: Actual EEROMS partition fs type different from configured fs type ('${ROMS_PART_FS_ACTUAL}' != '${ROMS_PART_FS}'), fixing '${ROMS_PART_FS_CONFIG}'"
          mount -o rw,remount /flash
          echo "${ROMS_PART_FS_ACTUAL}" > "${ROMS_PART_FS_CONFIG}"
          mount -o ro,remount /flash
        fi
        BOOL_EEROMS_EXIST='yes'
        ROMS_PART_FS="${ROMS_PART_FS_ACTUAL}"
      ;;
      # If fs is not supported, then consider EEROMS does not exist
      *)
        echo "ERROR: EEROMS partition fs not supported (${ROMS_PART_FS_ACTUAL}), please re-format it to one of the following fs: fat32, exfat, ext4, ntfs"
      ;;
    esac
  fi
}

is_storage_roms_mounted() {
  if mountpoint -q "${ROMS_DIR_ACTUAL}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

mount_eeroms() { # ${1} where to mount
  if [[ -L "${1}" || ! -d "${1}" ]]; then
    rm -f "${1}" &>/dev/null
    mkdir -p "${1}" &>/dev/null 
  fi
  mount -t "${ROMS_PART_FS}" "${ROMS_PART_TOKEN}" "${1}" &>/dev/null
  ROMS_PART_MOUNTPOINT="${1}"
}

umount_eeroms() {
  if [ "${ROMS_PART_PATH}" ]; then
    local i
    local MOUNTPOINT_RAW
    local MOUNTPOINT
    for MOUNTPOINT_RAW in $(grep "^${ROMS_PART_PATH} " '/proc/mounts' | cut -d ' ' -f 2); do
      MOUNTPOINT="$(printf ${MOUNTPOINT_RAW})"
      if [ "${MOUNTPOINT}" != "${UPDATE_DIR}" ]; then # Don't umount /storage/.update
        for i in {0..2}; do
          if grep -q "^${ROMS_PART_PATH} ${MOUNTPOINT_RAW} " '/proc/mounts' &>/dev/null; then
            sync
            umount -f "${MOUNTPOINT}" && break
          else
            break
          fi
          sleep 1
        done
      fi
    done
  else
    echo 'ERROR: Failed to find valid EEROMS partition, impossible to umount it'
    return 1
  fi
}

mount_eeroms_to_media() {
  if [ "${BOOL_EEROMS_EXIST}" ]; then
    if [ -d "${ROMS_DIR_MEDIA}" ]; then
      if grep -q "^${ROMS_PART_PATH} ${ROMS_DIR_MEDIA} " '/proc/mounts' &>/dev/null; then
        return
      else
        umount_recursively "${ROMS_DIR_MEDIA}" &>/dev/null
      fi
    fi
    umount_eeroms
    mount_eeroms "${ROMS_DIR_MEDIA}"
    echo "Note: Moved EEROMS partition to '${ROMS_DIR_MEDIA}', you can still access your roms from there, but the roms inside it can't be scanned and used by EmulationStation"
  fi
}

migrate_roms() { # ${1} source, ${2} target
  echo "Migrating roms: '${1}' => '${2}'"
  if mountpoint -q "${1}" &>/dev/null || mountpoint -q "${2}" &>/dev/null; then
    echo 'ERROR: Refuse to migrate as one of the source/target folder is a mountpoint!'
    return
  elif [[ -L "${2}" || ! -d "${2}" ]]; then # Easy, just move it
    rm -f "${2}" &>/dev/null
    mv "${1}" "${2}"
  else # We need to move-merge roms_backup into roms
    move_merge "${1}" "${2}"
    rm -rf "${1}" &>/dev/null
  fi
}

backup_roms() {
  echo 'Preparing to backup roms...'
  umount_recursively "${ROMS_DIR_ACTUAL}"
  umount_recursively "${ROMS_DIR_BACKUP}" # Usually /storage/roms_backup shouldn't be mounted, but we do this in case something wrong happened
  if is_storage_roms_mounted; then
    echo "ERROR: refuse to backup roms since '${ROMS_DIR_ACTUAL}' is a mountpoint, we will only backup roms if '${ROMS_DIR_ACTUAL}' is an folder directly stored on the underlying disk"
    return 1
  elif [ -d "${ROMS_DIR_ACTUAL}" ]; then
    echo 'Backing up roms...'
    migrate_roms "${ROMS_DIR_ACTUAL}" "${ROMS_DIR_BACKUP}"
  elif [ -e "${ROMS_DIR_ACTUAL}" ]; then
    # Don't mess up with our intended layout
    echo "WARNING: '${ROMS_DIR_BACKUP}' exists but is not a folder. No roms are backed up"
    return 1
  else
    echo 'Note: no roms need to be backed up'
  fi
}

restore_roms() {
  echo 'Preparing to restore roms...'
  umount_recursively "${ROMS_DIR_ACTUAL}"
  umount_recursively "${ROMS_DIR_BACKUP}" # Usually /storage/roms_backup shouldn't be mounted, but we do this in case something wrong happened
  if is_storage_roms_mounted; then
    echo "ERROR: refuse to restore roms since '${ROMS_DIR_ACTUAL}' is a mountpoint, we will only restore roms if '${ROMS_DIR_ACTUAL}' is an folder directly stored on the underlying disk"
    return 1
  elif [ -d "${ROMS_DIR_BACKUP}" ]; then
    echo 'Restoring roms...'
    migrate_roms "${ROMS_DIR_BACKUP}" "${ROMS_DIR_ACTUAL}"
  elif [ -e "${ROMS_DIR_BACKUP}" ]; then
    # Don't mess up with our intended layout
    echo "WARNING: '${ROMS_DIR_BACKUP}' exists but is not a folder. No roms are restored"
    return 1
  else
    echo 'Note: no roms need to be restored'
  fi
}

prepare_scan() {
  ROMS_PART_MOUNTPOINT=''
  echo "Preparing to scan for roms mounts..."
  echo "Stopping samba to avoid I/O conflicts..."
  systemctl stop smbd.service # Stop samba to avoid I/O conflicts
  LOAD_DELAY="$(get_ee_setting ee_load.delay)" # The delay is waited before we check for EEROMS
  [ "${LOAD_DELAY}" ] && sleep "${LOAD_DELAY}"
  scan_eeroms
}

ensure_dir_update_mounted() {
  if [[ -L "${UPDATE_DIR}" || ! -d "${UPDATE_DIR}" ]]; then
    rm -rf "${UPDATE_DIR}" &>/dev/null
    mkdir -p "${UPDATE_DIR}" &>/dev/null
  fi
  # This should only be useful for the very first boot after a user re-format EEROMS yet forgot to update ee_fstype
  if [ "${BOOL_EEROMS_EXIST}" ]  && ! mountpoint -q "${UPDATE_DIR}" &>/dev/null; then
    if [ -z "${ROMS_PART_MOUNTPOINT}" ]; then
      ROMS_PART_MOUNTPOINT="$(mktemp -d)"
      mount_eeroms "${ROMS_PART_MOUNTPOINT}"
      BOOL_ROMS_TEMP='yes'
    else
      BOOL_ROMS_TEMP=''
    fi
    ROMS_DIR_UPDATE="${ROMS_PART_MOUNTPOINT}/.update"
    if [[ -L "${ROMS_DIR_UPDATE}" || ! -d "${ROMS_DIR_UPDATE}" ]]; then
      rm -rf "${ROMS_DIR_UPDATE}" &>/dev/null
      mkdir -p "${ROMS_DIR_UPDATE}" &>/dev/null
    fi
    mount --bind "${ROMS_DIR_UPDATE}" "${UPDATE_DIR}" &>/dev/null
    if [ "${BOOL_ROMS_TEMP}" ]; then
      umount_recursively "${ROMS_PART_MOUNTPOINT}"
      rm -rf "${ROMS_PART_MOUNTPOINT}" &>/dev/null
    fi
  fi
}

finish_scan() {
  ensure_dir_update_mounted
  echo "Finished scanning for roms mounts..."
  echo "Bringing back samba..."
  systemctl start smbd.service
  
  #echo "Mounting ports_scripts..."
  #if [ -L "/storage/roms" ]; then
  #  local LINK=$(readlink /storage/roms)
  #else
  #  local LINK="/storage/roms"
  #fi
  # Just in case
  #mkdir -p "${LINK}/ports_scripts"
  #mkdir -p "/emuelec/ports"
  #mkdir -p "/storage/.tmp/ports-workdir"
  #umount "/storage/roms/ports_scripts" &>/dev/null
  #umount "/var/media/EEROMS/roms/ports_scripts" &>/dev/null

  #mount -t overlay ports -o lowerdir=/usr/bin/ports,upperdir=/emuelec/ports,workdir=/storage/.tmp/ports-workdir "${LINK}/ports_scripts"
}

if compgen -G /storage/.config/system.d/storage-roms*.mount &>/dev/null; then
  prepare_scan
  echo 'Note: mount unit starts with storage-roms found under /storage/.config/system.d, we will only try to mount these units and will not scan for external drives'
  # User defined mount units, most likely samba mounts
  BOOL_DAEMON_RELOADED=''
  SYSTEMD_UNIT_NAME='storage-roms.mount'
  SYSTEMD_UNIT_PATH="/storage/.config/system.d/${SYSTEMD_UNIT_NAME}"
  mount_samba_and_notice() {
    if [ -z "${BOOL_DAEMON_RELOAD}" ]; then # Only reload once, to save time
      BOOL_DAEMON_RELOADED='yes'
      systemctl daemon-reload
    fi
    systemctl start "${SYSTEMD_UNIT_NAME}" &>/dev/null
    systemctl is-active --quiet "${SYSTEMD_UNIT_NAME}" && echo "Mounted '${SYSTEMD_UNIT_PATH}' from samba roms"
  }
  # Only try to mount /storage/roms according to systemd if it's not mounted yet
  if [ -f "${SYSTEMD_UNIT_PATH}" ]; then
    echo "Note: Systemd mount unit '${SYSTEMD_UNIT_NAME}' found, will try to mount the whole roms folder"
    # backup_roms No need to backup roms
    umount_recursively "${ROMS_DIR_ACTUAL}"
    mount_eeroms_to_media
    if [[ -L "${ROMS_DIR_ACTUAL}" || ! -d "${ROMS_DIR_ACTUAL}" ]]; then
      rm -f "${ROMS_DIR_ACTUAL}" &>/dev/null
      mkdir -p "${ROMS_DIR_ACTUAL}"
    fi
    mount_samba_and_notice
  fi
  if ! is_storage_roms_mounted && [ "${BOOL_EEROMS_EXIST}" ]; then # If systemd mount units fail, then try to bring EEROMS back
    umount_eeroms
    mount_eeroms "${ROMS_DIR_ACTUAL}"
  fi
  is_storage_roms_mounted || restore_roms # If for some wierd reasons rom can't be mounted from the systemd unit and can't be brought back, then at least restore backed up roms
  IFS=$'\n'
  SYSTEMD_UNIT_PATHS=($(ls -d /storage/.config/system.d/storage-roms-*.mount 2>/dev/null | sort))
  unset IFS
  if [ "${#SYSTEMD_UNIT_PATHS[@]}" -gt 0 ]; then
    echo "Note: Multiple systemd mount units for folders under '${ROMS_DIR_ACTUAL}' found, will try to mount the roms folders for specific systems"
    for SYSTEMD_UNIT_PATH in "${SYSTEMD_UNIT_PATHS[@]}"; do
      [ ! -f "${SYSTEMD_UNIT_PATH}" ] && continue
      # Note: systemd unit names need specific escape rules, which should be done by systemd-escape, and I really don't think users would make themselves suffer and create units with name like that
      SYSTEMD_UNIT_NAME="$(basename ${SYSTEMD_UNIT_PATH})"
      MOUNTPOINT="$(grep ^Where= "${SYSTEMD_UNIT_PATH}")"
      umount_recursively "${MOUNTPOINT:6}"
      mount_samba_and_notice
    done
  fi
  finish_scan
elif [[ ! -f "${ROMS_DIR_ACTUAL}/${ROMS_FILE_MARK}" || "${ACTION_ES_RESTART}" ]]; then
  prepare_scan
  echo "Note: current '${ROMS_DIR_ACTUAL}' is not linked from external drives or es_restart requested, we'll try to scan for external roms"
  find_roms_mark() {
    echo "Finding roms mark (${ROMS_FILE_MARK})..."
    if ! compgen -G "${MEDIA_DIR}/${ROMS_PART_MATCHER}/${ROMS_DIR_NAME}" &>/dev/null; then
      echo "ERROR: no folders under '${MEDIA_DIR}' match the matcher '${ROMS_PART_MATCHER}' and contain roms folder, maybe you should adjust some settings?"
      ROMS_PATH_MARK=''
      return 1
    elif [ "${ROMS_PART_MATCHER}" == '*' ]; then
      ROMS_PATH_MARK="$(find "${MEDIA_DIR}/"*"/${ROMS_DIR_NAME}" -maxdepth 1 -name ${ROMS_FILE_MARK}* -not -path "${MEDIA_DIR}/${ROMS_PART_LABEL}/*" 2>/dev/null | head -n 1)" # Even we said the mark file should have no extension, but we still accept that, just in case
    else
      ROMS_PATH_MARK="$(find "${MEDIA_DIR}/${ROMS_PART_MATCHER}/${ROMS_DIR_NAME}" -maxdepth 1 -name ${ROMS_FILE_MARK}* -not -path "${MEDIA_DIR}/${ROMS_PART_LABEL}/*" 2>/dev/null | head -n 1)"
    fi
  }
  find_roms_mark
  if [ -z "${ROMS_PATH_MARK}" ]; then
    TRY=1
    RETRY="$(get_ee_setting ee_mount.retry)"
    if [ "${RETRY}" -ge 1 ]; then
      while [ "${TRY}" -le "${RETRY}" ] ; do
        echo "WARNING: Roms mark not found (${ROMS_FILE_MARK}), retrying (${TRY}/${RETRY})"
        find_roms_mark
        [ "${EE_ROMS_PATH_MARK}" ] && break
        let TRY++
        sleep 1
      done
    fi
  fi
  if [ -z "${ROMS_PATH_MARK}" ]; then
    echo "WARNING: No external mount mark found (${ROMS_FILE_MARK}), if you want to use external roms, make sure you set it correctly"
    # No external roms could be found, if EEROMS exists, make sure it's mounted, otherwise restore backed up roms if possible
    if [ "${BOOL_EEROMS_EXIST}" ]; then
      if ! is_storage_roms_mounted; then
        echo "Note: Remounting EEROMS to '${ROMS_DIR_ACTUAL}'"
        umount_eeroms 
        mount_eeroms "${ROMS_DIR_ACTUAL}"
      fi
    fi
    if ! is_storage_roms_mounted; then
      echo "WARNING: '${ROMS_DIR_ACTUAL}' is not a mountpoint, checking if we should restore backed up roms"
      restore_roms  # If for some wierd reason EEROMS can't be mounted, then at least restore backed up roms
    fi
  else
    echo "Note: External mount mark found (${ROMS_PATH_MARK})"
    if [[ -f "${ROMS_DIR_ACTUAL}/${ROMS_FILE_MARK}" && "$(readlink -f "${ROMS_DIR_ACTUAL}/${ROMS_FILE_MARK}")" == "$(readlink -f "${ROMS_PATH_MARK}")" ]]; then
      echo 'Note: This is the same external drive as we are using, no need to update'
    else
      echo "Trying to create a symbol link at '${ROMS_DIR_ACTUAL}' to it"
      umount_recursively "${ROMS_DIR_ACTUAL}"
      mount_eeroms_to_media
      backup_roms
      ROMS_DIR_EXTERNAL="$(dirname "${ROMS_PATH_MARK}")"
      echo "Using '${ROMS_DIR_EXTERNAL}' as the external roms dir"
      rm -rf "${ROMS_DIR_ACTUAL}" &>/dev/null
      if ln -sTf "${ROMS_DIR_EXTERNAL}" "${ROMS_DIR_ACTUAL}" &>/dev/null; then
        echo "Successfully create symbol link '${ROMS_DIR_ACTUAL}' pointing to '${ROMS_DIR_EXTERNAL}'"
      else
        echo "WARNING: Failed to create symbol link, restoring backed up roms if possible"
        restore_roms
      fi
    fi
  fi
  finish_scan
else
  echo 'Note: no need to scan external roms, mount_romfs skipped'
fi

find "${ROMS_DIR_BACKUP}" -maxdepth 0 -empty -exec rm -rf \{} \;

if [ "${ACTION_ES_RESTART}" ]; then
  echo 'Restarting EmulationStation as requested...'
  systemctl restart emustation.service
fi
