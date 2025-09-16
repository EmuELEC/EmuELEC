# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

import os
import subprocess
import xbmc
import xbmcaddon
import xbmcgui


class Monitor(xbmc.Monitor):

   def __init__(self, *args, **kwargs):
      xbmc.Monitor.__init__(self)
      self.setLocale()

   def onSettingsChanged(self):
      self.setLocale()

   def setLocale(self):
      addon = xbmcaddon.Addon()

      charmap = addon.getSetting('charmap')
      locale = addon.getSetting('locale')
      lang = locale + '.' + charmap

      path = addon.getAddonInfo('path')
      i18npath = os.path.join(path, 'i18n')
      locpath = os.path.join(path, 'locpath')
      localepath = os.path.join(locpath, lang)
      profiled = os.path.join(path, 'profile.d')
      profile = os.path.join(profiled, '10-locale.profile')

      strings = addon.getLocalizedString

      if os.path.isdir(locpath) == False:
         os.makedirs(locpath)

      if os.path.isdir(localepath) == False:
         os.environ['I18NPATH'] = i18npath
         rc = subprocess.run([os.path.join(path, 'bin/localedef'), '-v', '-f', charmap,
                              '-i', locale, localepath], capture_output=True,
                             stdin=subprocess.DEVNULL)

         if rc.returncode not in [0, 1]:
            xbmc.log(repr(rc), xbmc.LOGERROR)
            try:
               os.rmdir(localepath)
            except OSError as e:
               pass
            if os.path.isfile(profile):
               os.unlink(profile)
            xbmcgui.Dialog().ok('Locale', strings(30004).format(lang))
            return

      if os.path.isdir(profiled) == False:
         os.makedirs(profiled)

      file = open(profile, 'w')
      file.write('export LANG="' + lang + '"\n')
      file.write('export LOCPATH="' + locpath + '"\n')
      file.close()

      current = os.environ.get('LANG', '')
      if lang != current:
         if xbmcgui.Dialog().yesno('Locale', strings(30003).format(lang)
                                  ) == True:
            xbmc.restart()


if __name__ == '__main__':
   Monitor().waitForAbort()
