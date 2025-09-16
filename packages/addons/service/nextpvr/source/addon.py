# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

import urllib.request, urllib.parse, urllib.error, os, zipfile
from urllib.error import URLError
import urllib.parse as urlparse
import requests
import json
import subprocess

from  urllib.parse import parse_qs
import xbmc, xbmcvfs, xbmcgui, xbmcaddon
import shutil
import sys
import xml.etree.ElementTree as ET

temp = xbmcvfs.translatePath('special://temp')

ADDON_NAME = xbmcaddon.Addon().getAddonInfo('name')
LS = xbmcaddon.Addon().getLocalizedString

# Ignore isbn tables
SCANTABLES = ['atsc', 'dvb-c', 'dvb-s', 'dvb-t']
GENERIC_URL = 'https://nextpvr.com/stable/linux/NPVR.zip'

class Controller():

    def __init__(self):
        pass

    def downloadScanTable(self):
        # Taken from TVHeadend Addon
        try:
            url = 'https://github.com/tvheadend/dtv-scan-tables/archive/tvheadend.zip'
            archive = os.path.join(temp, 'dtv_scantables.zip')
            temp_folder = os.path.join(temp, 'dtv-scan-tables-tvheadend')
            dest_folder = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('path')), 'dtv-scan-tables')

            xbmcgui.Dialog().notification(ADDON_NAME, LS(30042), xbmcgui.NOTIFICATION_INFO)
            urllib.request.urlretrieve(url, archive)
            zip = zipfile.ZipFile(archive)
            if zip.testzip() is not None: raise zipfile.BadZipfile

            if os.path.exists(temp_folder): shutil.rmtree(temp_folder)
            if os.path.exists(dest_folder): shutil.rmtree(dest_folder)

            xbmcgui.Dialog().notification(ADDON_NAME, LS(30043), xbmcgui.NOTIFICATION_INFO)
            for idx, folder in enumerate(SCANTABLES):
                for z in zip.filelist:
                    if folder in z.filename: zip.extract(z.filename, temp)

            for folder in SCANTABLES:
                shutil.copytree(os.path.join(temp_folder, folder), os.path.join(dest_folder, folder))
            if os.path.exists(temp_folder): shutil.rmtree(temp_folder)
            os.remove(archive)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30039), xbmcgui.NOTIFICATION_INFO)
        except URLError as e:
            xbmc.log('Could not download file: %s' % e.reason, xbmc.LOGERROR)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30040), xbmcgui.NOTIFICATION_ERROR)
        except zipfile.BadZipfile:
            xbmc.log('Could not extract files from zip, bad zipfile', xbmc.LOGERROR)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30041), xbmcgui.NOTIFICATION_ERROR)

    def updateNextPVR(self):
        try:
            dest_folder = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('path')), 'nextpvr-bin')
            archive = os.path.join(temp, 'NPVR.zip')
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30011), xbmcgui.NOTIFICATION_INFO)
            urllib.request.urlretrieve(GENERIC_URL, archive)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30012), xbmcgui.NOTIFICATION_INFO)
            zip = zipfile.ZipFile(archive)
            if zip.testzip() is not None: raise zipfile.BadZipfile
            zip.close()
            command = 'unzip -o {0} -d {1} > /dev/null'.format(archive, dest_folder)
            xbmc.log('Running: %s' % command, xbmc.LOGDEBUG)
            os.system(command)
            os.remove(archive)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30039), xbmcgui.NOTIFICATION_INFO)
            xbmc.log('NPVR.zip installed', xbmc.LOGDEBUG)
            if xbmcgui.Dialog().yesno("NextPVR Server", LS(30020)):
                self.id = xbmcaddon.Addon().getAddonInfo('id')
                subprocess.call(['systemctl', 'restart', self.id])

        except URLError as e:
            xbmc.log('Could not download file: %s' % e.reason, xbmc.LOGERROR)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30040), xbmcgui.NOTIFICATION_ERROR)
        except zipfile.BadZipfile:
            xbmc.log('Could not extract files from zip, bad zipfile', xbmc.LOGERROR)
            xbmcgui.Dialog().notification(ADDON_NAME, LS(30041), xbmcgui.NOTIFICATION_ERROR)

    def sessionLogin(self):
        self.session = requests.session()
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0'
        }
        response = self.session.get(self.url, headers=headers)
        parsed = urlparse.urlparse(response.url)
        salt = parse_qs(parsed.query)['salt'][0]
        if self.hashedPassword == None:
            passwordHash = self.hashMe(self.password)
        else:
            passwordHash = self.hashedPassword
        combined = self.hashMe(salt + ':' + self.username + ':' + passwordHash)
        response = self.session.get(self.url + 'login.html?hash='+combined)
        if response.status_code != 200 and response.status_code != 302 :
            print(response.text, response.status_code)
            sys.exit()
        for cookie in self.session.cookies:
            self.session.cookies[cookie.name] = cookie.value

    def doSessionRequest5(self, method, isJSON = True):
        xbmc.log(method, xbmc.LOGDEBUG)
        retval = False
        getResult = None
        url = self.url + 'service?method=' + method
        try:
            request = self.session.get(url, headers={"Accept" : "application/json"})
            getResult = json.loads(request.text)
            if request.status_code == 200 :
                if 'stat' in getResult:
                    retval = getResult['stat'] == 'ok'
                else:
                    retval = True
            else:
                xbmc.log(getResult, xbmc.LOGERROR)

        except Exception as e:
            xbmc.log(str(e), xbmc.LOGERROR)

        return retval, getResult

    def hashMe (self, thedata):
        import hashlib
        h = hashlib.md5()
        h.update(thedata.encode('utf-8'))
        return h.hexdigest()

    def loginNextPVR(self):
        base = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('profile')), 'config/config.xml')
        tree = ET.parse(base)
        root = tree.getroot()
        child = root.find("WebServer")
        self.port = child.find('Port').text
        self.username = child.find('Username').text
        self.hashedPIN = child.find('PinMD5').text
        self.hashedPassword = child.find('Password').text.lower()
        self.ip = '127.0.0.1'
        self.url = 'http://{}:{}/'.format(self.ip, self.port)
        self.sessionLogin()


    def showMessage(self, message):
        xbmc.log(message, xbmc.LOGDEBUG)
        xbmcgui.Dialog().notification(ADDON_NAME, message, xbmcgui.NOTIFICATION_INFO)


    def updateEpg(self):
        self.loginNextPVR()
        self.doSessionRequest5('system.epg.update')
        self.doSessionRequest5('session.logout')
        self.showMessage(LS(30015))

    def updateM3u(self):
        self.loginNextPVR()
        self.doSessionRequest5('setting.m3u.update')
        self.doSessionRequest5('session.logout')
        self.showMessage(LS(30016))

    def rescanDevices(self):
        self.loginNextPVR()
        self.doSessionRequest5('setting.devices&refresh=true')
        self.doSessionRequest5('session.logout')
        self.showMessage(LS(30017))

    def transcodeHLS(self):
        base = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('profile')), 'config/config.xml')
        tree = ET.parse(base)
        parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
        tree = ET.parse(base, parser=parser)
        root = tree.getroot()
        parent = root.find("WebServer")
        child = parent.find('TranscodeHLS')
        if child.text == 'default':
            child.text = '-y [ANALYZE_DURATION] [SEEK] -i [SOURCE] -map_metadata -1 -threads [THREADS] -ignore_unknown -map 0:v:0? [PREFERRED_LANGUAGE] -map 0:a:[AUDIO_STREAM] -map -0:s -vcodec copy -acodec aac -ac 2 -c:s copy -hls_time [SEGMENT_DURATION] -start_number 0 -hls_list_size [SEGMENT_COUNT] -y [TARGET]'
        else:
            child.text = 'default'
        tree.write(base, encoding='utf-8')

        if child.text == 'default':
            self.showMessage(LS(30018))
        else:
            self.showMessage(LS(30019))

    def resetWebCredentials(self):
        rewrite = False
        base = os.path.join(xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('profile')), 'config/config.xml')
        tree = ET.parse(base)
        parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
        tree = ET.parse(base, parser=parser)
        root = tree.getroot()
        parent = root.find("WebServer")
        child = parent.find('Username')
        if child.text != 'admin':
            child.text = 'admin'
            rewrite = True
        child = parent.find('Password')
        if child.text != '5f4dcc3b5aa765d61d8327deb882cf99':
            child.text = '5f4dcc3b5aa765d61d8327deb882cf99'
            rewrite = True
        if rewrite:
            tree.write(base, encoding='utf-8')
            self.showMessage(LS(30046))


if __name__ == '__main__':
    option = Controller()
    try:
        if sys.argv[1] == 'getscantables':
            option.downloadScanTable()
        elif sys.argv[1] == 'updategeneric':
            option.updateNextPVR()
        elif sys.argv[1] == 'updateepg':
            option.updateEpg()
        elif sys.argv[1] == 'transcode':
            option.transcodeHLS()
        elif sys.argv[1] == 'updatem3u':
            option.updateM3u()
        elif sys.argv[1] == 'rescan':
            option.rescanDevices()
        elif sys.argv[1] == 'defaults':
            option.resetWebCredentials()
    except IndexError:
        pass
