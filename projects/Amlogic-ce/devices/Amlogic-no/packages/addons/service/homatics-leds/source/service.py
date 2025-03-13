# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

from time import sleep
import os.path
from threading import Thread, Event
import xbmc, xbmcaddon

sysfs = '/sys/devices/platform/soc/fe000000.apb4/fe06c000.i2c/i2c-3/3-003c/leds/bct3236/'
leds_count = 10  # do not change
delay = 90       # in milliseconds

#####################################################################
def myLog(msg, level = xbmc.LOGINFO):
  xbmc.log(addonid + ': ' + msg, level)

#####################################################################
def write_sysfs(which, data):
  if os.path.isfile(sysfs + which):
    with open(sysfs + which, 'w') as file:
      file.write(data)

#####################################################################
def led_on(pos, pos_min, pos_max, color):
  out_arr = []
  out_str = ''

  for i in range(leds_count):
    out_arr.append('000000')

  if pos >= 0:
    out_arr[pos] = color
  elif pos_min >= 0 and pos_max >= 0:
    for pos in range(pos_min, pos_max + 1):
      out_arr[pos] = color

  for i in range(leds_count):
    out_str += out_arr[i] + ' '

  #myLog('out_str: %s' % out_str)
  write_sysfs('colors', out_str)

#####################################################################
class myEffectThread(Thread):
  def __init__(self, color, run_daemon_mode = False):
    Thread.__init__(self)
    self.stop_event = Event()
    self.running = True
    self.color = color
    myLog('myEffectThread color %s' % self.color)

  def stop_event_is_set(self):
    if self.stop_event.is_set():
      self.stop_event.clear()
      self.running = False
      myLog('myEffectThread stopping')
      led_on(-1, -1, -1, '')
      return True
    else:
      return False

  def stop(self):
    self.stop_event.set()

  def stop_and_join(self):
    self.stop()

    try:
      self.join()
    except:
      pass

  def run(self):
    while self.running:
      if self.stop_event_is_set():
        break

      # to right
      for i in range(0, leds_count, 1):
        led_on(i, -1, -1, self.color)
        sleep(delay / 1000.0)

        if self.stop_event_is_set():
          break

      sleep(delay / 1000.0)

      # to left
      for i in range(9, -1, -1):
        led_on(i, -1, -1, self.color)
        sleep(delay / 1000.0)

        if self.stop_event_is_set():
          break

      sleep(delay / 1000.0)

#####################################################################
def setup():
  solid_effect = xbmcaddon.Addon().getSetting('solid_effect')
  myLog('solid_effect %s' % solid_effect)

  # set on/off/suspend colors and then start effect if active
  set_solid()

  if solid_effect == 'effect':
    myLog('setup effect')
    strip_color = xbmcaddon.Addon().getSetting('strip_color')
    strip_color = color_name_to_hex(strip_color)

    my_effect_thread = myEffectThread(strip_color, True)
    my_effect_thread.start()
  else:
    myLog('setup solid')
    my_effect_thread = None

  return my_effect_thread

#####################################################################
def set_solid():
  color_on = xbmcaddon.Addon().getSetting('color_on')
  color_off = xbmcaddon.Addon().getSetting('color_off')
  color_suspend = xbmcaddon.Addon().getSetting('color_suspend')
  number_leds = xbmcaddon.Addon().getSetting('number_leds')
  solid_color_type_on = xbmcaddon.Addon().getSetting('solid_color_type_on')

  if solid_color_type_on == 'name':
    color_on = xbmcaddon.Addon().getSetting('strip_color')
    color_on = color_name_to_hex(color_on)

  if number_leds == 'all':
    number_leds = 10
  else:
    number_leds = int(number_leds)

  myLog('set_solid color_on %s' % color_on)
  myLog('set_solid color_off %s' % color_off)
  myLog('set_solid color_suspend %s' % color_suspend)
  myLog('set_solid number_leds %d' % number_leds)

  write_sysfs('edge_color_on', color_on)
  write_sysfs('edge_color_off', color_off)
  write_sysfs('edge_color_suspend', color_suspend)

  # set only some LEDs on
  if number_leds == 1:
    led_on(4, -1, -1, color_on)
  elif number_leds == 2:
    led_on(-1, 4, 5, color_on)
  elif number_leds == 4:
    led_on(-1, 3, 6, color_on)
  elif number_leds == 6:
    led_on(-1, 2, 7, color_on)
  elif number_leds == 8:
    led_on(-1, 1, 8, color_on)

#####################################################################
def color_name_to_hex(color):
  if color == 'green':
    return '122e04'
  elif color == 'blue':
    return '101010'
  elif color == 'purple':
    return '800080'
  elif color == 'yellow':
    return 'ff4600'
  elif color == 'deepblue':
    return '0d00bf'
  elif color == 'magenta':
    return 'd8007a'
  elif color == 'orange':
    return 'f50e00'
  else:
    return 'ff0000'  # red
    
#####################################################################
class xbmcMonitor(xbmc.Monitor):
  def __init__(self, thread):
    xbmc.Monitor.__init__(self)
    self.my_effect_thread = thread

  def onSettingsChanged(self):
    myLog('settings changed, restart')

    if self.my_effect_thread is not None:
      self.my_effect_thread.stop_and_join()

    self.my_effect_thread = setup()

  def onNotification(self, sender, method, data):
    myLog('notification %s' % (method))
    if method == 'System.OnWake':
      if self.my_effect_thread is None:
        # set on/off/suspend colors
        set_solid()
    elif method == 'System.OnQuit':
      # set on/off/suspend colors which will be changed to off color
      set_solid()

#####################################################################
if __name__ == '__main__':
  addonid = xbmcaddon.Addon().getAddonInfo('id')
  led_on(-1, -1, -1, '')
  my_effect_thread = setup()
  monitor = xbmcMonitor(my_effect_thread)

  while not monitor.abortRequested():
    if monitor.waitForAbort(5):
      if my_effect_thread is not None:
        my_effect_thread.stop_and_join()

      myLog('finished')
      break
