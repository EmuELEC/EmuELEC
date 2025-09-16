# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2013 Stephan Raue (stephan@openelec.tv)

import os
import sys
import re
import subprocess
import shutil
import xmlpp
from xml.dom import minidom

__sundtek_userspace__ = '/storage/.kodi/userdata/addon_data/driver.dvb.sundtek-mediatv/'

######################################################################################################
# backup setting.xml file only if backup doesn't exist
def settings_backup(settings_xml):
  try:
    with open(settings_xml + '_orig') as f: pass
  except IOError as e:
    shutil.copyfile(settings_xml, settings_xml + '_orig')

######################################################################################################
# restore setting.xml file from backup
def settings_restore(settings_xml):
  try:
    shutil.copyfile(settings_xml + '_orig', settings_xml)
  except IOError as e:
    print 'Error restoring file:', settings_xml

######################################################################################################
# get hdhomerun supported devices on a system (only name like 101ADD2B-0)
def get_devices_hdhomerun():
  tuners = []
  try:
    p = os.popen("hdhomerun_config discover", "r")
    while 1:
      line = p.readline()
      if not line:
        break
      else:
        str = line.strip()
        match = re.search(r'hdhomerun device (.+) found at .+', line)
        if match:
          name = match.group(1)
          print name
          tuners.append(name)
  except IOError:
    print 'Error getting hdhomerun tuners info'
  return tuners

  """
libreelec:~ # hdhomerun_config discover
hdhomerun device 12345678 found at 192.168.0.3
  """

######################################################################################################
# get sundtek supported devices on a system (name, serial number, type)
def get_devices_sundtek(mediaclient_e):
  tuners = []
  try:
    p = os.popen(mediaclient_e, "r")
    while 1:
      line = p.readline()
      if not line:
        break
      else:
        str = line.strip()
        if str.startswith('device '):
          name = str[str.find("[")+1:str.find("]")]
          tuners.append([name, 0, 's'])

        if str.startswith('[SERIAL]:'):
          line = p.readline()
          str = line.strip()
          if str.startswith('ID:'):
            id = str.split(':');
            id = id[1].strip()
            tuners[len(tuners)-1] = [name, id, 's']

        if str.startswith('[DVB-C]:'):
          tuners[len(tuners)-1] = [name, id, 'c']
        elif str.startswith('[DVB-T]:'):
          tuners[len(tuners)-1] = [name, id, 'c']
        elif str.startswith('[DVB-T2]:'):
          tuners[len(tuners)-1] = [name, id, 'c']
  except IOError:
    print 'Error getting sundtek tuners info'
  return tuners

  """
root ~ # mediaclient -e
**** List of Media Hardware Devices ****
device 0: [Sundtek MediaTV Pro (USB 2.0)]  DVB-C, DVB-T, ANALOG-TV, FM-RADIO, REMOTE-CONTROL, OSS-AUDIO, RDS
  [BUS]:
     ID: 1-7
  [SERIAL]:
     ID: U110763295205
  [DVB-C]:
     FRONTEND: /dev/dvb/adapter0/frontend0
     DVR: /dev/dvb/adapter0/dvr0
     DMX: /dev/dvb/adapter0/demux0
  [DVB-T]:
     FRONTEND: /dev/dvb/adapter0/frontend0
     DVR: /dev/dvb/adapter0/dvr0
     DMX: /dev/dvb/adapter0/demux0
  [ANALOG-TV]:
     VIDEO0: /dev/video0
     VBI0: /dev/vbi0
  [FM-RADIO]:
     RADIO0: /dev/radio0
     RDS: /dev/rds0
  [REMOTECONTROL]:
     INPUT0: /dev/mediainput0
  [OSS]:
     OSS0: /dev/dsp0
  """

######################################################################################################
# parse settings.xml file
def parse_settings(settings_xml):
  try:
    xmldoc = minidom.parse(settings_xml)
    category = xmldoc.getElementsByTagName('category')
    return xmldoc
  except Exception as inst:
    print 'Error parse settings file', settings_xml
    return None

######################################################################################################
# remove all nodes with id started with ATTACHED_TUNER_
def remove_old_tuners(xmldoc):
  category = xmldoc.getElementsByTagName('category')
  for node_cat in category:
    setting = node_cat.getElementsByTagName('setting')
    for node_set in setting :
      if 'id' in node_set.attributes.keys() and not node_set.getAttribute('id').find('ATTACHED_TUNER_'):
        node_set.parentNode.removeChild(node_set)

######################################################################################################
# add new hdhomerun tuners
def add_hdhomerun(xmldoc, node_cat, tuners):
  for ix, tuner in enumerate(tuners):
    #tuner_var = tuner.replace('-', '_')
    tuner_var = tuner
    print tuner

    node1 = xmldoc.createElement("setting")
    node1.setAttribute("id", 'ATTACHED_TUNER_' + tuner_var + '_DVBMODE')
    node1.setAttribute("label", "tuner serial " + tuner_var)
    node1.setAttribute("type", 'labelenum')
    node1.setAttribute("default", 'auto')
    node1.setAttribute("values", 'auto|ATSC|DVB-C|DVB-T')
    node_cat.appendChild(node1)

    node2 = xmldoc.createElement("setting")
    node2.setAttribute("id", 'ATTACHED_TUNER_' + tuner_var + '_FULLNAME')
    node2.setAttribute("label", '9020')
    node2.setAttribute("type", 'bool')
    node2.setAttribute("default", 'false')
    node_cat.appendChild(node2)

    node3 = xmldoc.createElement("setting")
    node3.setAttribute("id", 'ATTACHED_TUNER_' + tuner_var + '_NUMBERS')
    node3.setAttribute("label", '9025')
    node3.setAttribute("type", 'labelenum')
    node3.setAttribute("default", '2')
    node3.setAttribute("values", '1|2|3|4|5|6|7|8')
    node_cat.appendChild(node3)

    node4 = xmldoc.createElement("setting")
    node4.setAttribute("id", 'ATTACHED_TUNER_' + tuner_var + '_DISABLE')
    node4.setAttribute("label", '9030')
    node4.setAttribute("type", 'bool')
    node4.setAttribute("default", 'false')
    node_cat.appendChild(node4)

  # for tuner

######################################################################################################
# add new sundtek tuners
def add_sundtek(xmldoc, node_cat, tuners):
  for ix, tuner in enumerate(tuners):
    tuner_name   = tuner[0]
    tuner_serial = tuner[1]
    tuner_type   = tuner[2]

    node1 = xmldoc.createElement("setting")
    node1.setAttribute("id", 'ATTACHED_TUNER_' + tuner_serial + '_DVBMODE')
    node1.setAttribute("label", tuner_name + ", " + tuner_serial)
    node1.setAttribute("type", 'labelenum')

    if (tuner_type == 's'):
      node1.setAttribute("default", 'DVB-S')
      node1.setAttribute("values", 'DVB-S')
    else:
      node1.setAttribute("default", 'DVB-C')
      node1.setAttribute("values", 'DVB-C|DVB-T')

    node_cat.appendChild(node1)

    node2 = xmldoc.createElement("setting")
    node2.setAttribute("id", 'ATTACHED_TUNER_' + tuner_serial + '_IRPROT')
    node2.setAttribute("label", '9020')
    node2.setAttribute("type", 'labelenum')
    node2.setAttribute("default", 'auto')
    node2.setAttribute("values", 'auto|RC5|NEC|RC6')
    node_cat.appendChild(node2)

    node3 = xmldoc.createElement("setting")
    node3.setAttribute("id", 'ATTACHED_TUNER_' + tuner_serial + '_KEYMAP')
    node3.setAttribute("label", '9030')
    node3.setAttribute("type", 'file')
    node3.setAttribute("mask", '*.map')
    node3.setAttribute("default", __sundtek_userspace__)
    node_cat.appendChild(node3)

  # for tuner

######################################################################################################
# add new ATTACHED_TUNER_ nodes for available tuners
def add_new_tuners(xmldoc, tuners, which):
  category = xmldoc.getElementsByTagName('category')
  for node_cat in category:
    setting = node_cat.getElementsByTagName('setting')
    for node_set in setting :
      if 'label' in node_set.attributes.keys() and '9010' in node_set.getAttribute('label'):
        if which == 'hdhomerun':
          add_hdhomerun(xmldoc, node_cat, tuners)
          break
        elif which == 'sundtek':
          add_sundtek(xmldoc, node_cat, tuners)
          break


######################################################################################################
# save settings.xml file back
def save_settings(settings_xml, xmldoc):
  try:
    outputfile = open(settings_xml, 'w')
    xmlpp.pprint(xmldoc.toxml(), output = outputfile, indent=2)
    outputfile.close()
  except IOError:
    print 'Error saving file:', settings_xml
    settings_restore(settings_xml)

######################################################################################################
# refresh hdhomerun tuners in settings.xml file
def refresh_hdhomerun_tuners(settings_xml):
  settings_backup(settings_xml)
  tuners = get_devices_hdhomerun()
  xmldoc = parse_settings(settings_xml)
  if xmldoc == None:
    print 'No hdhomerun tuners found'
  else:
    remove_old_tuners(xmldoc)
    add_new_tuners(xmldoc, tuners, 'hdhomerun')
    save_settings(settings_xml, xmldoc)

######################################################################################################
# refresh sundtek tuners in settings.xml file
def refresh_sundtek_tuners(settings_xml, mediaclient_e):
  settings_backup(settings_xml)
  tuners = get_devices_sundtek(mediaclient_e)
  xmldoc = parse_settings(settings_xml)
  if xmldoc == None:
    print 'No sundtek tuners found'
  else:
    remove_old_tuners(xmldoc)
    add_new_tuners(xmldoc, tuners, 'sundtek')
    save_settings(settings_xml, xmldoc)
