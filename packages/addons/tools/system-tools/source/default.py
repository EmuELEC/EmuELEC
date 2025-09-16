# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

import xbmcaddon
import xbmcgui
import subprocess
import re
import csv

with open('/etc/os-release') as stream:
    contents = stream.read().strip()
vars = re.findall(r"^[a-zA-Z0-9_]+=.*$", contents, flags=re.MULTILINE)
reader = csv.reader(vars, delimiter="=")
osrelease = dict(reader)

if osrelease['LIBREELEC_ARCH'] == 'x11.x86_64' or osrelease['LIBREELEC_ARCH'] == 'Generic-legacy.x86_64':
  yes = xbmcgui.Dialog().yesno('System Tools', 'This is a console-only addon.[CR][CR]Open a terminal window?',nolabel='No',yeslabel='Yes')
  if yes:
    subprocess.Popen(["systemd-run","sh","-c",". /etc/profile;cd;exec st -e sh -l"], shell=False, close_fds=True)
else:
  xbmcgui.Dialog().ok('System Tools', 'This is a console-only addon')
