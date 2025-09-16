# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

import os.path
import subprocess
import xbmcaddon
import xbmcgui

SNAPCLIENT = os.path.join(
    xbmcaddon.Addon().getAddonInfo('path'), 'bin', 'snapclient')

line = ''
card = ''
cards = []
lines = subprocess.run([SNAPCLIENT, '--list'], capture_output=True, text=True).stdout.splitlines()

for line in lines:
    if line != '':
        card = card + ' ' + line
    else:
        cards.append(card)
        card = ''

# If last line was not empty, make sure to add the last card
if line != '' and card != '':
    cards.append(card)

dialog = xbmcgui.Dialog()
dialog.select(xbmcaddon.Addon().getLocalizedString(30015), cards)
del dialog
