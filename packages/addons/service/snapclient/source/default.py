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
        self.player = Player()

    def onSettingsChanged(self):
        self.player.start('restart')


class Player(xbmc.Player):

    def __init__(self):
        super(Player, self).__init__(self)
        self.start('start')

    def onPlayBackEnded(self):
        if xbmcaddon.Addon().getSetting('sc_k') == 'true':
            xbmc.sleep(500)
            if not self.isPlaying():
                systemctl('start')

    def onPlayBackStarted(self):
        if xbmcaddon.Addon().getSetting('sc_k') == 'true':
            systemctl('stop')

    def onPlayBackStopped(self):
        if xbmcaddon.Addon().getSetting('sc_k') == 'true':
            systemctl('start')

    def start(self, command):
        if xbmcaddon.Addon().getSetting('sc_k') == 'true':
            if self.isPlaying():
                systemctl('stop')
            else:
                systemctl(command)
        else:
            systemctl(command)


if __name__ == '__main__':
    Monitor().waitForAbort()
