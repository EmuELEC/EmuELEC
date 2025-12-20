# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

import urllib.request, urllib.parse, urllib.error
import urllib.parse
import sys
import xbmc
import xbmcgui
import xbmcplugin
import xbmcaddon
import os
import subprocess

ADDON_ID = 'service.homatics-leds'
addon = xbmcaddon.Addon(ADDON_ID)

base_url = sys.argv[0]
addon_handle = int(sys.argv[1])
args = urllib.parse.parse_qs(sys.argv[2][1:])

def build_url(query):
  return base_url + '?' + urllib.parse.urlencode(query)

addon_icon = 'special://home/addons/service.homatics-leds/resources/icon.png'

addon_icon1 = 'special://home/addons/service.homatics-leds/resources/icon1.png'

addon_icon2 = 'special://home/addons/service.homatics-leds/resources/icon2.png'

addon_icon3 = 'special://home/addons/service.homatics-leds/resources/icon3.png'

addon_icon4 = 'special://home/addons/service.homatics-leds/resources/icon4.png'

addon_icon5 = 'special://home/addons/service.homatics-leds/resources/icon5.png'

addon_icon6 = 'special://home/addons/service.homatics-leds/resources/icon6.png'

addon_icon7 = 'special://home/addons/service.homatics-leds/resources/icon7.png'

addon_icon8 = 'special://home/addons/service.homatics-leds/resources/icon8.png'

addon_icon9 = 'special://home/addons/service.homatics-leds/resources/icon9.png'

mode = args.get('mode', None)

if mode is None:
  url = build_url({'mode': 'red', 'foldername': 'LEDs red'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32009))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon1, 'thumb' : addon_icon1})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'blue', 'foldername': 'LEDs blue'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32010))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon2, 'thumb' : addon_icon2})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'green', 'foldername': 'LEDs green'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32011))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon3, 'thumb' : addon_icon3})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'purple', 'foldername': 'LEDs purple'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32012))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon4, 'thumb' : addon_icon4})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'yellow', 'foldername': 'LEDs yellow'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32013))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon5, 'thumb' : addon_icon5})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'deepblue', 'foldername': 'LEDs deepblue'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32014))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon6, 'thumb' : addon_icon6})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'magenta', 'foldername': 'LEDs magenta'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32015))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon7, 'thumb' : addon_icon7})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'orange', 'foldername': 'LEDs orange'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32016))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon8, 'thumb' : addon_icon8})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  url = build_url({'mode': 'purpleN', 'foldername': 'LEDs straight purple'})
  li = xbmcgui.ListItem(addon.getLocalizedString(32017))
  li.setArt({'fanart': addon.getAddonInfo('fanart'), 'icon': addon_icon9, 'thumb' : addon_icon9})
  xbmcplugin.addDirectoryItem(handle=addon_handle, url=url, listitem=li, isFolder=False)

  xbmcplugin.endOfDirectory(addon_handle)
elif mode[0] == 'red' or mode[0] == 'orange' or mode[0] == 'green' or mode[0] == 'magenta' or mode[0] == 'deepblue' or mode[0] == 'blue' or mode[0] == 'purple' or mode[0] == 'yellow':
  xbmc.log('mode[0] %s' % mode[0], level=xbmc.LOGERROR)
  addon.setSetting('strip_color', mode[0])
  addon.setSetting('solid_color_type_on', 'name')
  addon.setSetting('solid_effect', 'effect')

  xbmc.executeJSONRPC('{"jsonrpc":"2.0","method":"Addons.SetAddonEnabled","id":8,"params":{"addonid":"%s","enabled":false}}'% ADDON_ID)
  xbmc.sleep(2000)
  xbmc.executeJSONRPC('{"jsonrpc":"2.0","method":"Addons.SetAddonEnabled","id":8,"params":{"addonid":"%s","enabled":true}}'% ADDON_ID)
elif mode[0] == 'purpleN':
  xbmc.log('mode[0] %s' % 'purpleN', level=xbmc.LOGERROR)
  addon.setSetting('strip_color', 'purple')
  addon.setSetting('solid_color_type_on', 'name')
  addon.setSetting('solid_effect', 'solid')

  xbmc.executeJSONRPC('{"jsonrpc":"2.0","method":"Addons.SetAddonEnabled","id":8,"params":{"addonid":"%s","enabled":false}}'% ADDON_ID)
  xbmc.sleep(2000)
  xbmc.executeJSONRPC('{"jsonrpc":"2.0","method":"Addons.SetAddonEnabled","id":8,"params":{"addonid":"%s","enabled":true}}'% ADDON_ID)
