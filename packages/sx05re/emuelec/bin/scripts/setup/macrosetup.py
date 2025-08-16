#!/usr/bin/env python3
from evdev import InputDevice, list_devices, ecodes as e
import json
import os
import time

CONFIG_FILE = "/storage/.config/emuelec/scripts/macro_config.json"

def map_controller_to_key(code):
    mapping = {
        e.BTN_DPAD_UP: e.KEY_UP,
        e.BTN_DPAD_DOWN: e.KEY_DOWN,
        e.BTN_DPAD_LEFT: e.KEY_LEFT,
        e.BTN_DPAD_RIGHT: e.KEY_RIGHT,
        e.BTN_SOUTH: e.KEY_Z,
        e.BTN_EAST: e.KEY_X,
        e.BTN_NORTH: e.KEY_A,
        e.BTN_WEST: e.KEY_S,
    }
    return mapping.get(code)

def save_config(data):
    with open(CONFIG_FILE, "w") as f:
        json.dump(data, f)
    print(f"\n✅ Configuration saved to {CONFIG_FILE}.")

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

def record_trigger_button(dev):
    print("\n🎯 Press the button that will later trigger the macro...")
    while True:
        for event in dev.read_loop():
            if event.type == e.EV_KEY and event.value == 1:
                if event.code != e.BTN_MODE:
                    print(f"Trigger button: Code {event.code}")
                    time.sleep(0.5)
                    return event.code

def record_macro_sequence(dev, trigger_code):
    print("\n⌨ Press the buttons for your macro (recording ends after a 3-second pause)...")
    macro_keys = []
    last_press_time = time.time()

    for event in dev.read_loop():
        if event.type == e.EV_KEY and event.value == 1:
            if event.code != trigger_code:
                macro_keys.append(event.code)
                last_press_time = time.time()
                print(f"→ Button added: Code {event.code}")
        if time.time() - last_press_time > 3:
            break

    if not macro_keys:
        print("❌ No buttons recorded!")
        return None

    mapped = [map_controller_to_key(c) for c in macro_keys if map_controller_to_key(c)]
    print(f"🎬 Macro recorded: {len(mapped)} valid keys")
    return mapped

def main():
    dev = wait_for_controller()
    trigger_code = record_trigger_button(dev)
    macro_keys = record_macro_sequence(dev, trigger_code)

    if macro_keys:
        save_config({
            "device_path": dev.path,
            "trigger_code": trigger_code,
            "macro_keys": macro_keys
        })
        print("\n✅ Setup complete! Start the macro later with:")
        print("python3 macrorun.py")

if __name__ == "__main__":
    main()