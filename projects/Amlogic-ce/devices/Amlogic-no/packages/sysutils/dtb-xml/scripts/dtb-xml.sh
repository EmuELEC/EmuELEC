#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)
#
#  Update dtb.img by dtb.xml
#
#####################################################
#
# Command Line Arguments
# -v = Show verbose output
# -m = migrate dtb.img settings to dtb.xml
#
#####################################################

verbose=0
changed=0
migrate=0
edid=0
BOOT_ROOT='/flash'
amlogic_dt_id=''

while [ $# -ne 0 ]; do
  arg="$1"
  case "$arg" in
      -v)
        verbose=1
        ;;
      -m)
        migrate=1
        ;;
      -e)
        edid=1
        ;;
      *)
        echo "Unknown option: '$arg'"
        exit
        ;;
  esac
  [ $# -gt 0 ] && shift
done

xml_file="$BOOT_ROOT/dtb.xml"
default_xml_file="/usr/share/bootloader/dtb.xml"
dtb_file="$BOOT_ROOT/dtb.img"
[ -f /proc/device-tree/amlogic-dt-id ] && amlogic_dt_id=$(tr -d '\0' < /proc/device-tree/amlogic-dt-id)
DT_ID=$(dtname)
edid_bin_file="/storage/.config/edid.bin"

#########################################################
# edid_to_xml
#########################################################
# Return 1 if dtb.img needs to be updated
function edid_to_xml() {
  ret=0

  if [ ! -f ${xml_file} ]; then
    log "File '${xml_file}' doesn't exist"
    return ${ret}
  fi

  # check the presence of the node
  node_name=$(xmlstarlet sel -t -m '/dtb-settings/custom_edid/edid/cmd/value' -v "name()" ${xml_file})
  if [ -z "${node_name}" ]; then
    log "Node 'custom_edid' doesn't exist"
    return ${ret}
  fi

  # read value from xml, this returns error code on empty node
  xml_file_hex=$(xmlstarlet sel -t -v '/dtb-settings/custom_edid/edid/cmd/value' ${xml_file})

  if [ -f ${edid_bin_file} ]; then
    # read binary file edid.bin to hex string
    edid_bin_hex=$(xxd -c 8192 -p ${edid_bin_file} | tr -d '\n')
    edid_bin_hex_hdr=$(echo ${edid_bin_hex} | head -c 16)

    if [ "${edid_bin_hex_hdr}" != "00ffffffffffff00" ]; then
      log "Found text 'edid.bin' file"
      edid_bin_hex=$(cat ${edid_bin_file} | tr -d '\r\n')
    else
      log "Found binary 'edid.bin' file"
    fi
  else
    log "No 'edid.bin' file found"
    edid_bin_hex=""
  fi

  # compare value from file and xml
  if [ "${edid_bin_hex}" != "${xml_file_hex}" ]; then
    log "Update 'custom_edid' with '${edid_bin_hex}'"
    xmlstarlet ed -L -u '/dtb-settings/custom_edid/edid/cmd/value' -v "${edid_bin_hex}" ${xml_file}
    ret=1
  fi

  log "Done"
  return ${ret}
}
#########################################################
# check_linux_version
#########################################################
# Return 1 if given kernel version is lower than current kernel version
function check_linux_version() {
    version_higher=$(uname -r | awk -F '.' \
      -v ker_ver=$1 -v maj_ver=$2 -v min_ver=$3 '{
        if ($1 > ker_ver) { print "Y"; }
        else if ($1 < ker_ver) { print "N"; }
        else {
          if ($2 > maj_ver) { print "Y"; }
          else if ($2 < maj_ver) { print "N"; }
          else {
            if ($3 >= min_ver) { print "Y"; }
            else { print "N"; }
          }
        }
      }')

    if [ "$version_higher" = "Y" ]; then
      return 0
    else
      return 1
    fi
}

#########################################################
# log
#########################################################
function log() {
  [ "$verbose" == 1 ] && echo "$@"
}

#########################################################
# update_migrated_xml
#########################################################
# Update a specified option node if value in dtb.img
# become applicable by parameter: $update_node
function update_migrated_xml() {
  update_node="$1"
  log " try to update migrated node '$update_node' by dtb.img"
  option_nodes=$(xmlstarlet sel -t -m "//$update_node/*" -v "name()" -n $xml_file)

  # check all options for specified migrated option node
  for option in $option_nodes; do
    cmd_count=$(xmlstarlet sel -t -c "count(//$update_node/$option/cmd)" $xml_file)

    if [ "$cmd_count" == 0 ]; then
      continue
    fi

    # check all commands for this current node of BOOT_ROOT dtb.xml if all commands are equal to dtb.img
    for cnt in $(seq 1 $cmd_count); do
      cmd_path=$(xmlstarlet sel -t -v "//$update_node/$option/cmd[$cnt]/@path" $xml_file)
      fdt_option=$(xmlstarlet sel -t -v "//$update_node/$option/cmd[$cnt]/@option" $xml_file)
      fdt_option=${fdt_option:-"t"}
      cmd_type=$(xmlstarlet sel -t -m "//$update_node/$option/cmd[$cnt]" -v "concat('-$fdt_option ', @type)" $xml_file)
      case "$fdt_option" in
          t)
            act_value=$(fdtget $amlogic_dt_id $cmd_type $dtb_file $cmd_path 2>/dev/null)
            if [ "$?" == 0 ]; then
              cmd_value=$(xmlstarlet sel -t -m "//$update_node/$option" -m "cmd[$cnt]/value" -v "concat(.,' ')" $xml_file)
              [ -n "$cmd_value" ] && cmd_value=${cmd_value::-1}
              [ -n "$cmd_value" ] && cmd_value=${cmd_value#"0x"}
              if [ "$act_value" != "$cmd_value" ]; then
                continue 2
              fi
            else
              continue 2
            fi
            ;;
          d|r)
            [ -n "$(fdtget $amlogic_dt_id $dtb_file $cmd_path 2>/dev/null)" ] && continue 2
            ;;
      esac
    done
    # option status changed to applicable, update BOOT_ROOT dtb.xml by current status
    name_option=$(xmlstarlet sel -t -v "//$update_node/$option/@name" -n $xml_file)
    xmlstarlet ed -L -u "//$update_node/@status" -v "$name_option" $xml_file
    xmlstarlet ed -L -d "//$update_node/${update_node}_migrated" $xml_file
    changed=1
    log " option status changed from '$node_status' to '$name_option'"
    node_status="$name_option"
    break
  done
  # option is still not applicable
  if [ "$changed" == 0 ]; then
    log " option status stay unchanged at '$node_status'"
  fi
  log ""
}

#########################################################
# migrate_dtb_to_xml
#########################################################
# Migrate BOOT_ROOT dtb.xml from dtb.img
#
# * If no BOOT_ROOT dtb.xml does exist the current values
#   from dtb.img are migrated by reading each single
#   option status value from current dtb.img
# * If no matching option is found in BOOT_ROOT dtb.xml
#   set the option status to 'migrated'
function migrate_dtb_to_xml() {
  log ""
  log "Migrate dtb.xml from dtb.img"
  log ""

  # loop through all BOOT_ROOT dtb.xml options
  root_nodes=$(xmlstarlet sel -t -m '/*/*' -v "name()" -n $xml_file)
  for node in $root_nodes; do
    node_status=$(xmlstarlet sel -t -v "//$node/@status" $xml_file)
    log "------------------------------------------"
    log " node:  $node, status: '$node_status'"
    option_nodes=$(xmlstarlet sel -t -m "//$node/*" -v "name()" -n $xml_file)
    name_option_available=0

    # check if the node apply at all by dt_id
    # if not skip any further check and set to 'migrated'
    node_dt_id=$(xmlstarlet sel -t -v "//$node/@dt_id" $xml_file)
    if [ -n "$node_dt_id" ]; then
      log " dt_id: $node_dt_id,  coreelec-dt-id: $DT_ID"

      dt_id_match=0
      for dt_id in $node_dt_id; do
        eval "
          case \$DT_ID in
            *"$dt_id"*)
              dt_id_match=1
              ;;
          esac
        "
      done

      if [ "$dt_id_match" == 0 -o -z "$DT_ID" ]; then
        option_nodes=""
      fi
    fi

    for option in $option_nodes; do
      cmd_count=$(xmlstarlet sel -t -c "count(//$node/$option/cmd)" $xml_file)
      cmd_remove_exist=$(xmlstarlet sel -t -m "//$node/$option/cmd" -i '@option="d"' -o "1" -b -i '@option="r"' -o "1" $xml_file)
      # check all commands for this current node of BOOT_ROOT dtb.xml if all commands are equal to dtb.img
      for cnt in $(seq 1 $cmd_count); do
        cmd_path=$(xmlstarlet sel -t -v "//$node/$option/cmd[$cnt]/@path" $xml_file)
        fdt_option=$(xmlstarlet sel -t -v "//$update_node/$option/cmd[$cnt]/@option" $xml_file)
        fdt_option=${fdt_option:-"t"}
        cmd_type=$(xmlstarlet sel -t -m "//$node/$option/cmd[$cnt]" -v "concat('-$fdt_option ', @type)" $xml_file)
        case "$fdt_option" in
            t)
              act_value=$(fdtget $amlogic_dt_id $cmd_type $dtb_file $cmd_path 2>/dev/null)
              if [ "$?" == 0 ]; then
                cmd_value=$(xmlstarlet sel -t -m "//$node/$option" -m "cmd[$cnt]/value" -v "concat(.,' ')" $xml_file)
                [ -n "$cmd_value" ] && cmd_value=${cmd_value::-1}
                [ -n "$cmd_value" ] && cmd_value=${cmd_value#"0x"}
                if [ "$act_value" != "$cmd_value" ]; then
                  continue 2
                fi
              else
                continue 2
              fi
              ;;
            d|r)
              [ -z "$(fdtget $amlogic_dt_id $dtb_file $cmd_path 2>/dev/null)" -a -n "$cmd_remove_exist" ] || continue 2
              ;;
      esac
      done
      name_option_available=1
      name_option=$(xmlstarlet sel -t -v "//$node/$option/@name" -n $xml_file)
      # if option is available set current status in BOOT_ROOT dtb.xml
      if [ "$node_status" != "$name_option" ]; then
        # special handling to migrate heartbeat setting from config.ini on Odroid devices
        case $node in
          sys_led)
            case $DT_ID in
              *odroid*)
                log " detected Odroid device, migrate heartbeat led setting from config.ini"
                heartbeat="$( cat /flash/config.ini | awk -F "=" '/^heartbeat=/{gsub(/"|\047/,"",$2); print $2}')"
                if [ "$heartbeat" == "0" ]; then
                  name_option="off"
                  fdtput $amlogic_dt_id -t s $dtb_file /gpioleds/sys_led linux,default-trigger none
                  echo none > /sys/class/leds/sys_led/trigger
                fi
                ;;
            esac
            ;;
          wol)
            if check_linux_version 5 15 137; then
              wol="$( cat /flash/config.ini | awk -F "=" '/^wol=/{gsub(/"|\047/,"",$2); print $2}')"
              log " migrate WOL setting ($wol) from config.ini"
              if [ "$wol" == "1" ]; then
                name_option="on"
                fdtput $amlogic_dt_id -t i $dtb_file /soc/ethernet@fdc00000 wol 1
              fi
            fi
            ;;
        esac

        log " migrate dtb.xml node '$node' to '$name_option'"
        xmlstarlet ed -L -u "//$node/@status" -v "$name_option" $xml_file
        continue 2
      else
        log " option status already set, do not migrate option"
      fi
    done
    # if the option is not available in dtb.img set option status to 'migrated' with current dtb.img value
    if [ "$name_option_available" == 0 ]; then
      xmlstarlet ed -L -s "//$node" -t elem -n "${node}_migrated" $xml_file
      xmlstarlet ed -L -u "//$node/@status" -v "migrated" $xml_file
      xmlstarlet ed -L -i "//${node}_migrated" -t attr -n "name" -v "migrated" $xml_file
      log " option not applicable by default dtb.xml, migrate to '${node}_migrated'"
    fi
  done
  log "------------------------------------------"
  log ""
}

#########################################################
# update_dtb_by_dtb_xml
#########################################################
# Update dtb.img by BOOT_ROOT dtb.xml
#
# * Check if the option in BOOT_ROOT dtb.xml does include
#   commands at all
# * Check if the option in BOOT_ROOT dtb.xml commands are
#   different and update dtb.img if needed
# * If dtb.img path is not found set the option to
#   'migrated' as not applicable
# * If option is set to 'migrated' check if it became
#   applicable after dtb.img update
function update_dtb_by_dtb_xml() {
  root_nodes=$(xmlstarlet sel -t -m '/*/*' -v "name()" -n $xml_file)

  log ""
  for node in $root_nodes; do
    log "------------------------------------------"
    log " node:   $node"

    node_status=$(xmlstarlet sel -t -v "//$node/@status" $xml_file)
    log " status: $node_status"

    node_dt_id=$(xmlstarlet sel -t -v "//$node/@dt_id" $xml_file)

    # check if dt_id is set for this node
    # if yes compare if the setting does apply for this $dtb_file
    # if not skip node and set to 'migrated' to hide the option in CoreELEC settings
    if [ -n "$node_dt_id" ]; then
      log " dt_id: $node_dt_id"
      log " coreelec-dt-id: $DT_ID"

      dt_id_match=0
      for dt_id in $node_dt_id; do
        eval "
          case \$DT_ID in
            *"$dt_id"*)
              dt_id_match=1
              ;;
          esac
        "
      done

      if [ "$dt_id_match" == 0 -o -z "$DT_ID" ]; then
        log ""
        log " not applicable as dt_id does not match"
        log ""
        xmlstarlet ed -L -u "//$node/@status" -v "migrated" $xml_file
        continue
      fi
    fi
    log ""

    # check if node is 'migrated' and update if possible
    if [ "$node_status" == "migrated" ]; then
      update_migrated_xml $node
    fi

    # check if node does include commands to be executed
    cmd_count=$(xmlstarlet sel -t -c "count(//$node/node()[@name='$node_status']/cmd)" $xml_file)
    cmd_remove_exist=$(xmlstarlet sel -t -m "//$node/*/cmd" -i '@option="d"' -o "1" -b -i '@option="r"' -o "1" $xml_file)

    if [ "$cmd_count" == 0 ]; then
      log " no cmd for node status '$node_status' found"
      continue
    fi

    # check all commands for this current node of BOOT_ROOT dtb.xml if all commands are equal to dtb.img
    for cnt in $(seq 1 $cmd_count); do
      cmd_path=$(xmlstarlet sel -t -v "//$node/node()[@name='$node_status']/cmd[$cnt]/@path" $xml_file)
      fdt_option=$(xmlstarlet sel -t -v "//$node/node()[@name='$node_status']/cmd[$cnt]/@option" $xml_file)
      fdt_option=${fdt_option:-"t"}
      cmd_type=$(xmlstarlet sel -t -m "//$node/node()[@name='$node_status']/cmd[$cnt]" -v "concat('-${fdt_option} ', @type)" $xml_file)

      # check if node commands does exist in dtb.img at all
      case "$fdt_option" in
          t)
            act_value=$(fdtget $amlogic_dt_id $cmd_type $dtb_file $cmd_path 2>/dev/null)
            if [ "$?" == "0" -o -z "$act_value" -a -n "$cmd_remove_exist" ]; then
              cmd_value=$(xmlstarlet sel -t -m "//$node/node()[@name='$node_status']" -m "cmd[$cnt]/value" -v "concat('\"', .,'\" ')" $xml_file)
              [ -n "$cmd_value" ] && cmd_value=${cmd_value::-1}
              cmd="fdtput $amlogic_dt_id $cmd_type $dtb_file $cmd_path $cmd_value"
              cmd_value="${cmd_value//\"}"
              [ -n "$cmd_value" ] && cmd_value=${cmd_value#"0x"}
              # check if dtb.img value does match with current BOOT_ROOT dtb.xml status
              if [ "$act_value" != "$cmd_value" ]; then
                eval $cmd
                log " cmd[$cnt]: changed, $cmd_path: '$act_value' -> '$cmd_value', result: $?"
                changed=1
              else
                log " cmd[$cnt]: unchanged, $cmd_path: '$cmd_value' == '$act_value'"
              fi
            else
              log " not applicable"
              xmlstarlet ed -L -u "//$node/@status" -v "migrated" $xml_file
              continue 2
            fi
            ;;
          d|r)
            if [ -z "$(fdtget $amlogic_dt_id $dtb_file $cmd_path 2>/dev/null)" ]; then
              log " cmd[$cnt]: unchanged, still not exist"
            else
              cmd="fdtput $amlogic_dt_id $cmd_type $dtb_file $cmd_path"
              eval $cmd
              log " cmd[$cnt]: changed, $cmd_path: run option '$fdt_option', result: $?"
              changed=1
            fi
            ;;
      esac
    done
  done
  log "------------------------------------------"
  log ""
}

#########################################################
# update_dtb_xml
#########################################################
# Update BOOT_ROOT dtb.xml by default dtb.xml
#
# * Update whole BOOT_ROOT dtb.xml by default dtb.xml
#   if dtb-settings version is higher
# * Check if a new node got introduced by default dtb.xml
# * Check if default dtb.xml version is higher than
#   BOOT_ROOT dtb.xml version and update if needed
function update_dtb_xml() {
  root_node_version=$(xmlstarlet sel -t -v "//dtb-settings/@version" $xml_file)
  default_root_node_version=$(xmlstarlet sel -t -v "//dtb-settings/@version" $default_xml_file)

  log ""
  log "------------------------------------------"
  log " dtb-settings version:           $root_node_version"
  log " dtb-settings default version:   $default_root_node_version"

  # default dtb.xml version changed, overwrite BOOT_ROOT dtb.xml
  if [ $root_node_version -lt $default_root_node_version ]; then
    log " update complete dtb.xml by default dtb.xml"
    cp -p $default_xml_file $xml_file
  fi

  root_nodes=$(xmlstarlet sel -t -m '/*/*' -v "name()" -n $xml_file)
  default_root_nodes=$(xmlstarlet sel -t -m '/*/*' -v "name()" -n $default_xml_file)

  # compare all default dtb.xml nodes with BOOT_ROOT dtb.xml
  for default_node in $default_root_nodes; do
    log "------------------------------------------"
    log " default node:   $default_node"

    default_node_status=$(xmlstarlet sel -t -v "//$default_node/@status" $default_xml_file)
    default_node_version=$(xmlstarlet sel -t -v "//$default_node/@version" $default_xml_file)
    log " default status: $default_node_status, version: $default_node_version"
    node_status=$(xmlstarlet sel -t -v "//$default_node/@status" $xml_file)
    # new node in default dtb.xml found, copy whole node
    if [ -z "$node_status" ]; then
      log " node in current dtb.xml not found, get it from default dtb.xml"
      new_node=$(xmlstarlet sel -t -c "//$default_node" $default_xml_file)
      xmlstarlet ed --subnode "/dtb-settings" -t text -n "" -v "$new_node" $xml_file | \
              xmlstarlet unesc | xmlstarlet format > tmp_file
      mv tmp_file $xml_file
    # node already exist in BOOT_ROOT dtb.xml, check if version update
    else
      node_version=$(xmlstarlet sel -t -v "//$default_node/@version" $xml_file)
      log " status: $node_status, version: $node_version"
      # newer version update node
      if [ $node_version -lt $default_node_version ]; then
        log " update node to version $default_node_version"
        xmlstarlet ed -L -d "//$default_node" $xml_file
        new_node=$(xmlstarlet sel -t -c "//$default_node" $default_xml_file)
        xmlstarlet ed --subnode "/dtb-settings" -t text -n "" -v "$new_node" $xml_file | \
                xmlstarlet unesc | xmlstarlet format > tmp_file
        mv tmp_file $xml_file
        option_nodes=$(xmlstarlet sel -t -m "//$default_node/*" -v "name()" -n $xml_file)
        # check if old status still apply and set it if true
        for option in $option_nodes; do
          option_node_name=$(xmlstarlet sel -t -v "//$default_node/$option/@name" $xml_file)
          if [ "$node_status" == "$option_node_name" ]; then
            xmlstarlet ed -L -u "//$default_node/@status" -v "$node_status" $xml_file
            log " updated node status to: $node_status"
            continue 2
          fi
        done
      fi
    fi
  done

  # compare all user dtb.xml nodes with default dtb.xml
  for node in $root_nodes; do
    log "------------------------------------------"
    log " node:   $node"
    node_status=$(xmlstarlet sel -t -v "//$node/@status" $default_xml_file)
    if [ -z "$node_status" ]; then
      xmlstarlet ed -L -d "//$node" $xml_file
      log " node got removed by default dtb.xml"
    else
      log " node still in use by default dtb.xml"
    fi
  done

  log "------------------------------------------"
  log ""
}

#########################################################
# main script
#########################################################

if [ ! -f $dtb_file ]; then
  log "Error, not found: $dtb_file, exit now"
  exit 2
fi

# check if BOOT_ROOT is mounted as 'ro'
grep -q " $BOOT_ROOT vfat ro," /proc/mounts
rw="$?"

# remount as 'rw' if needed
if [ "$rw" == "0" ]; then
  log "Try to remount '$BOOT_ROOT' in 'rw' mode"
  mount -o rw,remount "$BOOT_ROOT"
  if [ "$?" != "0" ]; then
    echo "Failed to remount '$BOOT_ROOT' in 'rw' mode"
    exit 12
  fi
fi

# copy default dtb.xml to BOOT_ROOT if not found
if [ ! -f $xml_file ]; then
  if [ -f $default_xml_file ]; then
    log "Creating dtb.xml..."
    cp -p $default_xml_file $xml_file
  else
    log "Error, not found: '$default_xml_file', exit now"
    exit 2
  fi
fi

if [ -n "$amlogic_dt_id" ]; then
  log "Using amlogic-dt-id: $amlogic_dt_id"
  amlogic_dt_id="-a $amlogic_dt_id"
fi

# handle script parameter
if [ "$migrate" == 1 ]; then
  migrate_dtb_to_xml
elif [ "$edid" == 1 ]; then
  log "Try parsing of custom edid.bin"
  edid_to_xml

  if [ "$?" = "1" ]; then
    update_dtb_xml
    update_dtb_by_dtb_xml
  fi
else
  update_dtb_xml
  update_dtb_by_dtb_xml
fi

# remount as 'ro' if it was 'ro' before
if [ "$rw" == "0" ]; then
  log "Try to remount '$BOOT_ROOT' in 'ro' mode"
  mount -o ro,remount "$BOOT_ROOT"
  if [ "$?" != "0" ]; then
    echo "Failed to remount '$BOOT_ROOT' in 'ro' mode"
    exit 12
  fi
fi

exit $changed
