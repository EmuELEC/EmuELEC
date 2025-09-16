# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

import json
import subprocess
import xbmc
import xbmcaddon
import xbmcgui


def jsonrpc(request):
    return json.loads(xbmc.executeJSONRPC(json.dumps(request)))


def disable_conflicting(conficting,
        message='{that} conflicts with {this} and has been disabled'):
    is_enabled = {'jsonrpc': '2.0', 'method': 'Addons.GetAddonDetails', 'id': 1,
                  'params': {'addonid': conficting, 'properties': ['enabled']}}
    disable = {'jsonrpc': '2.0', 'method': 'Addons.SetAddonEnabled', 'id': 1,
               'params': {'addonid': conficting, 'enabled': False}}
    try:
        if jsonrpc(is_enabled)['result']['addon']['enabled']:
            this = xbmcaddon.Addon().getAddonInfo('name')
            that = xbmcaddon.Addon(conficting).getAddonInfo('name')
            jsonrpc(disable)
            dialog = xbmcgui.Dialog()
            dialog.ok(this, message.format(
                this=this, that=that))
            del dialog
    except KeyError:
        pass


class Monitor(xbmc.Monitor):

    def __init__(self, *args, **kwargs):
        xbmc.Monitor.__init__(self)
        self.id = xbmcaddon.Addon().getAddonInfo('id')

    def onSettingsChanged(self):
        subprocess.call(['systemctl', 'restart', self.id])


if __name__ == '__main__':
    disable_conflicting('service.emby')
    Monitor().waitForAbort()
