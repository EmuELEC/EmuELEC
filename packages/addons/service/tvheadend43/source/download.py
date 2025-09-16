# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

import urllib.request, urllib.parse, urllib.error, os, zipfile
from urllib.error import URLError
import xbmc, xbmcvfs, xbmcgui, xbmcaddon
import shutil
import sys

url = 'https://github.com/tvheadend/dtv-scan-tables/archive/tvheadend.zip'
temp = xbmcvfs.translatePath('special://temp')
temp_folder = os.path.join(temp, 'dtv-scan-tables-tvheadend')
dest_folder = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('path')), 'dvb-scan')
archive = os.path.join(temp, 'dtv_scantables.zip')

ADDON_NAME = xbmcaddon.Addon().getAddonInfo('name')
LS = xbmcaddon.Addon().getLocalizedString
SCANTABLES = ['atsc', 'channels-conf', 'dvb-c', 'dvb-s', 'dvb-t', 'isdb-t']

class DownLoader():

    def __init__(self):
        self.dp = xbmcgui.DialogProgressBG()

    def download(self, url, dest):
        try:
            self.dp.create(ADDON_NAME, LS(30042))
            urllib.request.urlretrieve(url, dest, reporthook=self._pbhook)
            self.dp.close()
            zip = zipfile.ZipFile(archive)
            if zip.testzip() is not None: raise zipfile.BadZipfile

            if os.path.exists(temp_folder): shutil.rmtree(temp_folder)
            if os.path.exists(dest_folder): shutil.rmtree(dest_folder)

            self.dp.create(ADDON_NAME, LS(30043))
            for idx, folder in enumerate(SCANTABLES):
                self._pbhook(idx, 1, len(SCANTABLES) - 1)
                for z in zip.filelist:
                    if folder in z.filename: zip.extract(z.filename, temp)

            self.dp.close()
            for folder in SCANTABLES:
                shutil.copytree(os.path.join(temp_folder, folder), os.path.join(dest_folder, folder))

            xbmcgui.Dialog().notification(ADDON_NAME, LS(30039), xbmcgui.NOTIFICATION_INFO)
        except URLError as e:
            xbmc.log('Could not download file: %s' % e.reason, xbmc.LOGERROR)
            self.dp.close()
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30040), xbmcgui.NOTIFICATION_ERROR)
        except zipfile.BadZipfile:
            xbmc.log('Could not extract files from zip, bad zipfile', xbmc.LOGERROR)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30041), xbmcgui.NOTIFICATION_ERROR)

    def _pbhook(self, numblocks, blocksize, filesize):
            percent = int((numblocks * blocksize * 100) / filesize)
            self.dp.update(percent)


if __name__ == '__main__':
    try:
        if sys.argv[1] == 'getscantables':
            dl = DownLoader()
            dl.download(url, archive)
    except IndexError:
        pass

