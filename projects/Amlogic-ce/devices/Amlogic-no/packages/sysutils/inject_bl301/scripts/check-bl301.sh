#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
#
#  Detect BL301 injection
#
#####################################################
#
# Comand Line Arguments
# -v = Show verbose output
#
#####################################################

VERBOSE=0
INSTALLED=0

if [ "${1}" = "-v" ]; then
  VERBOSE=1
fi

if [ -e /usr/sbin/inject_bl301 ]; then
  inject_bl301 -i
  if [ ${?} = 1 ]; then
    INSTALLED=1
  fi
fi

if [ "${VERBOSE}" = 1 ]; then
  if [ "${INSTALLED}" = 1 ]; then
    echo "CoreELEC BL30 Installed"
  else
    echo "CoreELEC BL30 Not found"
  fi
fi
exit ${INSTALLED}
