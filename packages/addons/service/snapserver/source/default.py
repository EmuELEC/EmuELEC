# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

import subprocess
import xbmc
import xbmcaddon


def systemctl(command):
    subprocess.call(
        ['systemctl', command, xbmcaddon.Addon().getAddonInfo('id')])


class Monitor(xbmc.Monitor):

    def __init__(self, *args, **kwargs):
        xbmc.Monitor.__init__(self)

    def onSettingsChanged(self):
        systemctl('restart')


if __name__ == '__main__':
    Monitor().waitForAbort()
