# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

import os
import sys
import subprocess
import xbmcaddon
import xbmcvfs

__settings__      = xbmcaddon.Addon(id = 'driver.dvb.sundtek-mediatv')
__cwd__           = __settings__.getAddonInfo('path')
__resources_lib__ = xbmcvfs.translatePath(os.path.join(__cwd__, 'resources', 'lib'))
__settings_xml__  = xbmcvfs.translatePath(os.path.join(__cwd__, 'resources', 'settings.xml'))

__mediaclient__   = xbmcvfs.translatePath(os.path.join(__cwd__, 'bin', 'mediaclient'))
__mediaclient_e__ = __mediaclient__ + ' -e'
__update_sh__     = xbmcvfs.translatePath(os.path.join(__cwd__, 'bin', 'sundtek-update-driver.sh'))

if len(sys.argv) == 2:
  if sys.argv[1] == 'refresh_tuners':
    print('sundtek refresh tuners')
    sys.path.append(__resources_lib__)
    from functions import refresh_sundtek_tuners
    refresh_sundtek_tuners(__settings_xml__, __mediaclient_e__)
    __settings__.openSettings()
  elif sys.argv[1] == 'update_driver':
    print('sundtek update driver')
    proc = subprocess.Popen([__update_sh__], shell = True)
    return_code = proc.wait()
    print('sundtek update driver return value', return_code)
    __settings__.openSettings()
