# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

import os
import socket
import sys
from threading import Thread
import xbmc
import xbmcgui
import xbmcaddon

TEXT_ALIGN_LEFT = 0
TEXT_ALIGN_RIGHT = 1
TEXT_ALIGN_CENTER_X = 2
TEXT_ALIGN_CENTER_Y = 4
TEXT_ALIGN_RIGHT_CENTER_Y = 5
TEXT_ALIGN_LEFT_CENTER_X_CENTER_Y = 6
ACTION_PREVIOUS_MENU = 10
ACTION_BACKSPACE = 92

SOCK_PATH = "/tmp/ts_calibrate.socket"
TSLIB_EDGE_OFFEST = 50
CROSSHAIR_IMAGE_SIZE = 23
CROSSHAIR_IMAGE_OFFSET = 11
SKIN_WIDTH  = 1280   # we are using 720p skin
SKIN_HEIGHT =  720

class coordinates:
  var_x = 0
  var_y = 0

def server_thread(conn, self):
  while True:
    data = conn.recv(128)
    if not data:
      break

    self.currentTarget = self.currentTarget + 1
    if self.currentTarget > 0:
      self.removeControl(self.targetImage)

    if self.currentTarget == 5:
      xbmcgui.Dialog().ok("Calibration", "Calibration done.")
      break

    self.info.setLabel("Touch '" + data + "' crosshair")
    self.targetImage = xbmcgui.ControlImage(
      self.touch_points[self.currentTarget].var_x - CROSSHAIR_IMAGE_OFFSET,
      self.touch_points[self.currentTarget].var_y - CROSSHAIR_IMAGE_OFFSET,
      CROSSHAIR_IMAGE_SIZE, CROSSHAIR_IMAGE_SIZE,
      self.crosshair_path, colorDiffuse='0x00000000')
    self.addControl(self.targetImage)

  # out of loop, close connection
  conn.close()
  os.remove(SOCK_PATH)
  self.retval = 0
  self.close()

class ts_calibrate(xbmcgui.WindowDialog):
  def __init__(self):
    self.retval = 0
    self.media_path=os.path.join(addon.getAddonInfo('path'), 'resources','media') + '/'
    self.crosshair_path = self.media_path + 'crosshair.png'
    self.currentTarget = -1

    self.edge_offset_x = TSLIB_EDGE_OFFEST * SKIN_WIDTH / self.getWidth()
    self.edge_offset_y = TSLIB_EDGE_OFFEST * SKIN_HEIGHT / self.getHeight()

    self.touch_points = [coordinates() for i in range(5)]
    self.touch_points[0].var_x = self.edge_offset_x
    self.touch_points[0].var_y = self.edge_offset_y
    self.touch_points[1].var_x = SKIN_WIDTH - self.edge_offset_x
    self.touch_points[1].var_y = self.edge_offset_y
    self.touch_points[2].var_x = SKIN_WIDTH - self.edge_offset_x
    self.touch_points[2].var_y = SKIN_HEIGHT - self.edge_offset_y
    self.touch_points[3].var_x = self.edge_offset_x
    self.touch_points[3].var_y = SKIN_HEIGHT - self.edge_offset_y
    self.touch_points[4].var_x = SKIN_WIDTH / 2
    self.touch_points[4].var_y = SKIN_HEIGHT / 2

    self.background = xbmcgui.ControlImage(0, 0, SKIN_WIDTH, SKIN_HEIGHT,
          self.media_path + 'background.jpg', colorDiffuse = '0xffffffff')
    self.addControl(self.background)

    tmp_str  = "Tslib/Kodi calibration utility\n\nTouch crosshair to calibrate"
    tmp_str += "\n\nresolution: " + str(self.getWidth()) + "x" + str(self.getHeight())
    tmp_str += "\nskin: " + str(SKIN_WIDTH) + "x" + str(SKIN_HEIGHT)

    self.about = xbmcgui.ControlLabel(
      10, 80, SKIN_WIDTH, 400,
      "", textColor = '0xffffffff', font = 'font25', alignment = TEXT_ALIGN_CENTER_X)
    self.addControl(self.about)
    self.about.setLabel(tmp_str)

    self.info = xbmcgui.ControlLabel(
      20, SKIN_HEIGHT/2 - 40,
      1000, 400,
      "", textColor = '0xffffffff', font = 'font30', alignment = TEXT_ALIGN_LEFT)
    self.addControl(self.info)
    self.info.setLabel("")

    if os.path.exists(SOCK_PATH):
      os.remove(SOCK_PATH)

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(SOCK_PATH)
    sock.listen(1)

    # enter calibration mode
    os.system("killall -SIGUSR1 ts_uinput_touch")

    print 'Waiting for calibration connection'
    conn, addr = sock.accept()
    print 'Calibration connection accepted'

    self.t = Thread(target=server_thread, args=(conn, self,))
    self.t.start()

  def onAction(self, action):
    if action == ACTION_PREVIOUS_MENU or action == ACTION_BACKSPACE:
      self.retval = 0
      self.close()

addon = xbmcaddon.Addon(id = 'service.touchscreen')
finished = False

while finished == False:
  dialog = ts_calibrate()
  dialog.doModal()

  if dialog.retval == 0:
    finished = True
  del dialog

del addon
# exit calibration mode
os.system("killall -SIGUSR2 ts_uinput_touch")

if os.path.exists(SOCK_PATH):
  os.remove(SOCK_PATH)
      