#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
#
#  Update BL301 injection
#
#####################################################
#
# Comand Line Arguments
# -v = Show verbose output
#
#####################################################

VERBOSE=0
INSTALLED=0
UPDATE=1
RET=0

if [ "${1}" = "-v" ]; then
  VERBOSE=1
fi

if [ -e /usr/lib/coreelec/check-bl301 ]; then
  /usr/lib/coreelec/check-bl301
  INSTALLED=${?}
  if [ "${INSTALLED}" = 1 ]; then
    touch /run/bl301_injected
  fi
fi

if [ -e /usr/sbin/inject_bl301 ] && [ "${INSTALLED}" = 1 ]; then
  inject_bl301 -Y > /storage/update-bl301.log
  UPDATE=${?}
fi

if [ "${VERBOSE}" = 1 ]; then
  if [ "${INSTALLED}" = 1 ] && [ "${UPDATE}" = 0 ]; then
    echo "CoreELEC BL301 got updated"
  elif [ "${INSTALLED}" = 1 ] && [ "${UPDATE}" = 1 ]; then
    echo "CoreELEC BL301 installed but no update needed"
  elif [ "${INSTALLED}" = 1 ]; then
    echo "CoreELEC BL301 installed but error on update: " ${UPDATE}
    RET=${UPDATE}
  elif [ "${INSTALLED}" = 0 ]; then
    echo "CoreELEC BL301 not installed"
  fi
fi

if [ "${INSTALLED}" = 1 ] && [ "${UPDATE}" = 0 ]; then
  sync && reboot
fi

exit ${RET}
