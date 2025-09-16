# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

import xbmc
import xbmcgui
import xbmcaddon

__scriptid__ = 'service.touchscreen'
__addon__    = xbmcaddon.Addon(id=__scriptid__)
_            = __addon__.getLocalizedString

# http://forum.kodi.tv/showthread.php?tid=230766
def handle_wait(time_to_wait, title, text):
    dialog = xbmcgui.DialogProgress()
    ret = dialog.create(' ' + title)
    secs = 0
    percent = 0
    increment = int(100 / time_to_wait)

    while secs < time_to_wait:
        secs += 1
        percent = increment*secs
        secs_left = time_to_wait - secs
        remaining_display = (_(2030).encode('utf-8')) % secs_left
        dialog.update(percent, text, "", remaining_display)
        xbmc.sleep(1000)

    dialog.close()
    return False

# how long to lock the screen
lock_secs = 30
handle_wait(lock_secs, _(2010).encode('utf-8'), _(2020).encode('utf-8'))
