#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

read_firmware_version() {
  local firmware_file="${1}"
  minor=0
  batch=0

  if [ -f "${firmware_file}" ]; then
    local offset=0
    magic=$(echo $(hexdump -e '1/4 "%s"' -n 4 -s ${offset} ${firmware_file}) | rev)

    if [[ ${magic} != 'NEWP' && ${magic} != 'PACK' ]]; then
      offset=256
      magic=$(echo $(hexdump -e '1/4 "%s"' -n 4 -s ${offset} ${firmware_file}) | rev)

      if [[ ${magic} != 'PACK' ]]; then
        break
      fi
    fi

    minor=$(hexdump -e '"%d"' -n 1 -s $((16 + ${offset})) ${firmware_file})
    batch=$(hexdump -e '"%d"' -n 1 -s $((20 + ${offset})) ${firmware_file})
  fi

  echo 'minor="${minor}"; batch="${batch}"'
}
