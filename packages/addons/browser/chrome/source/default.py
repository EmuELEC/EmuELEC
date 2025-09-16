# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

import json
import linecache
import os
import shlex
import subprocess
import sys
import time

import xbmc
import xbmcaddon


__addon__ = xbmcaddon.Addon();
__path__  = os.path.join(__addon__.getAddonInfo('path'), 'bin')

pauseXBMC = __addon__.getSetting("PAUSE_XBMC")

def pauseXbmc():
  if pauseXBMC == "true":
    xbmc.executebuiltin("PlayerControl(Stop)")
    xbmc.audioSuspend()
    xbmc.enableNavSounds(False)

def resumeXbmc():
  if pauseXBMC == "true":
    xbmc.audioResume()
    xbmc.enableNavSounds(True)

def _print_exception():
  exc_type, exc_obj, tb = sys.exc_info()
  frame = tb.tb_frame
  lineno = tb.tb_lineno
  filename = frame.f_code.co_filename
  linecache.checkcache(filename)
  line = linecache.getline(filename, lineno, frame.f_globals)
  xbmc.log(f'## Chrome Addon Error: in ({filename}, line {lineno}\n"{line.strip()}"):\n{repr(exc_obj)}', xbmc.LOGERROR)

def startchrome(args):
  try:
    chrome_env = {
      'VAAPI_MODE': __addon__.getSetting('VAAPI_MODE'),
      'WINDOW_MODE': __addon__.getSetting('WINDOW_MODE'),
      'RASTER_MODE': __addon__.getSetting('RASTER_MODE'),
      'DARK_MODE': __addon__.getSetting('DARK_MODE')
    }

    # sound settings as environment variable
    if __addon__.getSetting('USE_CUST_AUDIODEVICE') == 'true':
      audio_device = __addon__.getSetting('CUST_AUDIODEVICE_STR')
    else:
      audio_device = getAudioDevice()
    chrome_env['AUDIO_DEVICE_TYPE'] = getAudioDeviceType(audio_device)
    if chrome_env['AUDIO_DEVICE_TYPE'] == 'ALSA':
      alsa_device = getAlsaAudioDevice(audio_device)
      chrome_env['ALSA_DEVICE'] = alsa_device if alsa_device else ''

    # chrome user-agent string
    if __addon__.getSetting('USE_CUST_USERAGENT') == 'true':
      chrome_env['USER_AGENT'] = __addon__.getSetting('CUST_USERAGENT_STR')

    # launch chrome
    new_env = os.environ.copy()
    new_env.update(chrome_env)
    chrome_execute = ([os.path.join(__path__, 'chrome-start')]
                      + args
                      + [__addon__.getSetting('HOMEPAGE')])
    subprocess.call(chrome_execute, env=new_env)
  except Exception:
    _print_exception()
    xbmc.log(f'## Chrome Addon Error: chrome env: {chrome_env}, audio device: {audio_device}', xbmc.LOGERROR)

def isRunning(pname):
  '''Returns True/False if pname is running'''
  running_commands = subprocess.run(shlex.split('ps -Ao comm'), text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  return pname in running_commands.stdout

def getAudioDevice():
  return json.loads(xbmc.executeJSONRPC(json.dumps({
                      "jsonrpc": "2.0",
                      "method": "Settings.GetSettingValue",
                      "params": {
                                  "setting": "audiooutput.audiodevice",
                                },
                      "id": 1,
                   })))['result']['value']

def getAudioDeviceType(dev):
  if dev:
    if dev.startswith("ALSA:"):
      return "ALSA"
    elif dev.startswith("PULSE:"):
      return "PULSE"
    else:
      # backwards compatibility of device string
      return "ALSA"
  return "ALSA"

def getAlsaAudioDevice(dev):
  if not dev.startswith('ALSA:'):
    return dev
  dev = dev.split("ALSA:")[1]
  if dev == "@":
    return None
  if dev.startswith("@:"):
    dev = dev.split("@:")[1]
  if dev.startswith("CARD="):
    dev = f'plughw:{dev}'
  return dev

if (not __addon__.getSetting("firstrun")):
  __addon__.setSetting("firstrun", "1")
  __addon__.openSettings()

try:
  args = sys.argv[1:]
except Exception:
  args = ''

if args == 'widevine':
  install_widevine()
elif args == 'flash':
  install_flash()
else:
  if not isRunning('chrome'):
    pauseXbmc()
    startchrome(args)
    while isRunning('chrome'):
      time.sleep(1)
    resumeXbmc()

del __addon__
