# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

import xbmcaddon
import xbmcgui

dialog = xbmcgui.Dialog()
strings  = xbmcaddon.Addon().getLocalizedString

dialog.ok(strings(30000), strings(30001))
