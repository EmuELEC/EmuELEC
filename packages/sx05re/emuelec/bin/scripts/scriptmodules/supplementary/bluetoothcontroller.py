#!/usr/bin/env python

# - "curses" menu based on https://stackoverflow.com/a/14205494

import curses,sys,time
from bluetool import Bluetooth
from curses import panel

class Menu(object):
    def __init__(self, items, stdscreen):
        self.window = stdscreen.subwin(0, 0)
        self.window.keypad(1)
        self.panel = panel.new_panel(self.window)
        self.panel.hide()
        panel.update_panels()

        self.position = 0
        self.items = items
        self.items.append(("Back / Exit", "exit"))

    def navigate(self, n):
        self.position += n
        if self.position < 0:
            self.position = 0
        elif self.position >= len(self.items):
            self.position = len(self.items) - 1

    def display(self):
        self.panel.top()
        self.panel.show()
        self.window.clear()

        while True:
            self.window.refresh()
            curses.doupdate()
            for index, item in enumerate(self.items):
                if index == self.position:
                    mode = curses.A_REVERSE
                else:
                    mode = curses.A_NORMAL

                msg = "%d. %s" % (index, item[0])
                self.window.addstr(1 + index, 1, msg, mode)

            key = self.window.getch()

            if key in [curses.KEY_ENTER, ord("\n")]:
                if self.position == len(self.items) - 1:
                    break
                else:
                    self.items[self.position][1]()

            elif key == curses.KEY_UP:
                self.navigate(-1)

            elif key == curses.KEY_DOWN:
                self.navigate(1)

        self.window.clear()
        self.panel.hide()
        panel.update_panels()
        curses.doupdate()

class MyApp(object):
    def __init__(self, stdscreen):
        self.scan_timeout = 90
        self.bt = Bluetooth()
        self.bt.start_scanning(self.scan_timeout)

        self.screen = stdscreen
        curses.curs_set(0)
        mainMenu = [
            ('Rescan devices\t\t(scans for {} seconds in background, system bus will be processed every 10 seconds)'.format(self.scan_timeout), self.rescan_devices),
            ('Trust controller\t\t(shows only untrusted pairable controllers)', self.trust_controller_menu),
            ('Pair controller\t\t(shows only unpaired pairable controllers)', self.pair_controller_menu),
            ('Connect controller\t\t(shows only paired and trusted connectable controllers)', self.connect_device_menu),
            ('Disconnect controller\t(shows only connected controllers)', self.disconnect_device_menu),
            ('Remove controller\t\t(shows only trusted, paired OR connected controllers)', self.remove_device_menu),
        ]
        self.make_menu(mainMenu)
        self.menu.display()

    def make_menu(self, menulist):
        self.menu = Menu(menulist, self.screen)

    def trust_controller_menu(self):
        properties = [
            'Icon',
            'RSSI',
            'Trusted',
        ]
        menu = []
        for device in self.bt.get_available_devices():
            mac_address = device['mac_address'].decode('utf-8')
            for property in properties:
                device[property] = self.bt.get_device_property(mac_address,property)
            if ((device['Icon'] == 'input-gaming') and (device['Trusted'] == 0)):
                menu.append(('{}\t{}\tRSSI: {}'.format(device['mac_address'].decode('utf-8'),device['name'].decode('utf-8'),device['RSSI']),self.trust_controller))
        self.make_menu(menu)
        self.menu.display()

    def trust_controller(self):
        mac = self.get_selected_device()[0]
        self.bt.trust(mac)
        if self.bt.get_device_property(mac,'Trusted') == 1:
            self.menu.items[self.menu.position] = ('MAC {} ({}) trusted!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)
        else:
            self.menu.items[self.menu.position] = ('Error trusting MAC {} ({})!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)

    def pair_controller_menu(self):
        properties = [
            'Icon',
            'Paired',
            'RSSI',
            'Trusted',
        ]
        menu = []
        for device in self.bt.get_devices_to_pair():
            mac_address = device['mac_address'].decode('utf-8')
            for property in properties:
                device[property] = self.bt.get_device_property(mac_address,property)
            if ((device['Icon'] == 'input-gaming') and (device['Trusted'] == 1) and device['Paired'] == 0):
                menu.append(('{}\t{}\tRSSI: {}'.format(device['mac_address'].decode('utf-8'),device['name'].decode('utf-8'),device['RSSI']),self.pair_controller))
        self.make_menu(menu)
        self.menu.display()

    def pair_controller(self):
        mac = self.get_selected_device()[0]
        self.bt.pair(mac)
        if self.bt.get_device_property(mac,'Paired') == 1:
            self.menu.items[self.menu.position] = ('MAC {} ({}) paired!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)
        else:
            self.menu.items[self.menu.position] = ('Error paring MAC {} ({})!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)        

    def connect_device_menu(self):
        properties = [
            'Icon',
            'RSSI',
            'Connected',
            'Paired',
            'Trusted',
        ]
        menu = []
        for device in self.bt.get_available_devices():
            mac_address = device['mac_address'].decode('utf-8')
            for property in properties:
                device[property] = self.bt.get_device_property(mac_address,property)
            if ((device['Icon'] == 'input-gaming') and (device['Paired'] == 1) and (device['Trusted'] == 1) and (device['Connected'] == 0)):
                menu.append(('{}\t{}\tRSSI: {}'.format(device['mac_address'].decode('utf-8'),device['name'].decode('utf-8'),device['RSSI']),self.connect_device))
        self.make_menu(menu)
        self.menu.display()

    def connect_device(self):
        mac = self.get_selected_device()[0]
        self.bt.connect(mac)
        if self.bt.get_device_property(mac,'Connected') == 1:
            self.menu.items[self.menu.position] = ('MAC {} ({}) connected!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)
        else:
            self.menu.items[self.menu.position] = ('Error connecting MAC {} ({})!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)        


    def disconnect_device_menu(self):
        properties = [
            'Icon',
            'Connected',
            'RSSI',
        ]
        menu = []
        for device in self.bt.get_connected_devices():
            mac_address = device['mac_address'].decode('utf-8')
            for property in properties:
                device[property] = self.bt.get_device_property(mac_address,property)
            if ((device['Icon'] == 'input-gaming') and (device['Connected'] == 1)):
                menu.append(('{}\t{}\tRSSI: {}'.format(device['mac_address'].decode('utf-8'),device['name'].decode('utf-8'),device['RSSI']),self.disconnect_device))
        self.make_menu(menu)
        self.menu.display()

    def disconnect_device(self):
        mac = self.get_selected_device()[0]
        self.bt.disconnect(mac)
        if self.bt.get_device_property(mac,'Connected') == 0:
            self.menu.items[self.menu.position] = ('MAC {} ({}) disconnected!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)
        else:
            self.menu.items[self.menu.position] = ('Error disconnecting MAC {} ({})!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)          

    def remove_device_menu(self):
        properties = [
            'Icon',
            'Paired',
            'Trusted',
            'RSSI',
            'Blocked',
            'Connected',
        ]
        menu = []
        for device in self.bt.get_available_devices():
            mac_address = device['mac_address'].decode('utf-8')
            for property in properties:
                device[property] = self.bt.get_device_property(mac_address,property)
            if ((device['Icon'] == 'input-gaming') and ((device['Paired'] == 1) or (device['Trusted'] == 1) or (device['Blocked'] == 1))):
                menu.append(('{}\t{}\tRSSI: {}\tTrusted: {}\tPaired: {}\tConnected: {}\tBlocked: {}'.format(device['mac_address'].decode('utf-8'),device['name'].decode('utf-8'),device['RSSI'],device['Trusted'],device['Paired'],device['Connected'],device['Blocked']),self.remove_device))
        self.make_menu(menu)
        self.menu.display()

    def remove_device(self):
        mac = self.get_selected_device()[0]
        self.bt.remove(mac)
        self.menu.items[self.menu.position] = ('MAC {} ({}) removed!\n'.format(mac,self.get_selected_device()[1]),self.navigate_to_back)

    def rescan_devices(self):
        self.menu.window.addstr(9, 1, 'Scanning for device for {} seconds in background now, please refresh views...'.format(self.scan_timeout), curses.A_NORMAL)
        self.bt.start_scanning(self.scan_timeout)

    def get_selected_device(self):
        return(self.menu.items[self.menu.position][0].split('\t'))

    def navigate_to_back(self):
        self.menu.navigate(len(self.menu.items) -1)

if __name__ == "__main__":
    if (len(sys.argv) == 1):
        bt = Bluetooth()
        print('Scanning for available devices for 90 seconds, please wait...')
        bt.start_scanning(90)
        time.sleep(15)
        print('Getting pairable devices, please wait...')
        devices = bt.get_devices_to_pair()
        print(devices)
        for device in devices:
            mac = device['mac_address'].decode('utf-8')
            name = device['name'].decode('utf-8')
            print('Found MAC: {}\tName: {}'.format(mac,name))
            if bt.get_device_property(mac,'Icon') == 'input-gaming':
                print('Found controller {} Name: {}, trusting...'.format(mac,name))
                bt.trust(mac)
                if bt.get_device_property(mac,'Trusted') == 1:
                    print('Trusted {}, quick pause, then pairing...'.format(name))
                    time.sleep(5)
                    bt.pair(mac)
                    if bt.get_device_property(mac,'Paired') == 1:
                        print('Paired {}, quick pause, then connecting...'.format(name))
                        time.sleep(5)
                        bt.connect(mac)
                        if bt.get_device_property(mac,'Connected') == 1:
                            print('Connected {}, exiting...'.format(name))
    else:
        curses.wrapper(MyApp)
