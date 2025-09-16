# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.tv)

# detect legacy kernel installs and abort to prevent upgrades
if [[ "$(uname -r)" = "3.14."* ]] || [[ "$(uname -r)" = "4.9."* ]]; then
  echo "Update from older kernel is not supported!"
  sleep 10
  exit 1
fi

DEVICE_OLD=$(echo "${1}" | cut -d. -f1)
DEVICE_NEW=$(echo "${2}" | cut -d. -f1)

# allow upgrades between aarch64 and arm images on same device
if [ "${DEVICE_OLD}" = "${DEVICE_NEW}" ]; then
  exit 0
else
  exit 1
fi
