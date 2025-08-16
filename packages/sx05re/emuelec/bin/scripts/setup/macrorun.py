#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, '/storage/.config/emuelec/scripts/')
from evdev import InputDevice, list_devices, ecodes as e
from evdev import UInput
import json
import time
import os

CONFIG_FILE = "/storage/.config/emuelec/scripts/macro_config.json"

def wait_for_controller():
    print("\n🔌 Waiting for controller...")
    while True:
        devices = [InputDevice(path) for path in list_devices()]
        for dev in devices:
            if dev.capabilities().get(e.EV_KEY):
                keys = dev.capabilities()[e.EV_KEY]
                if any(btn in keys for btn in [e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST]):
                    print(f"🎮 Controller found: {dev.name} ({dev.path})")
                    return dev
        time.sleep(1)

def load_config():
    if not os.path.exists(CONFIG_FILE):
        print("❌ No saved configuration found. Please run Setup first!")
        exit(1)
    with open(CONFIG_FILE, "r") as f:
        return json.load(f)

def run_macro_mode(dev, trigger_code, macro_keys):
    ui = UInput({e.EV_KEY: list(set(macro_keys))}, name="Virtual-Macro", bustype=e.BUS_USB)
    trigger_pressed = False
    macro_executed = False
    press_start = 0

    print("\n🚀 Macro active! Press the trigger to execute. Hold for 3 seconds to exit.")

    for event in dev.read_loop():
        if event.type == e.EV_KEY and event.code == trigger_code:
            if event.value == 1:
                trigger_pressed = True
                macro_executed = False
                press_start = time.time()
            elif event.value == 0:
                if trigger_pressed:
                    hold_time = time.time() - press_start
                    trigger_pressed = False
                    if hold_time >= 3:
                        print("👋 Exiting...")
                        ui.close()
                        return
                    elif not macro_executed:
                        print("▶ Executing macro...")
                        for key in macro_keys:
                            ui.write(e.EV_KEY, key, 1)
                            ui.syn()
                            time.sleep(0.05)
                            ui.write(e.EV_KEY, key, 0)
                            ui.syn()

        if trigger_pressed and not macro_executed and time.time() - press_start >= 0.1:
            macro_executed = True
            print("▶ Executing macro...")
            for key in macro_keys:
                ui.write(e.EV_KEY, key, 1)
                ui.syn()
                time.sleep(0.05)
                ui.write(e.EV_KEY, key, 0)
                ui.syn()

def main():
    config = load_config()
    dev = wait_for_controller()
    run_macro_mode(dev, config["trigger_code"], config["macro_keys"])

if __name__ == "__main__":
    main()