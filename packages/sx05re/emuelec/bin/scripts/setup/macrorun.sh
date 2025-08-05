#!/bin/bash

CONFIG_FILE="/storage/.config/emuelec/scripts/macro_config.json"

# If config is missing → start setup
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠ No configuration found."
    echo "▶ Starting setup..."
    python3 - <<'EOF'
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
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
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
        print("\n✅ Setup complete!")

if __name__ == "__main__":
    main()
EOF

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ No configuration created. Exiting."
        exit 1
    fi
fi

# Start macro in the background
(
python3 - <<'EOF'
import sys
import os
from evdev import InputDevice, list_devices, ecodes as e
from evdev import UInput
import json
import time

CONFIG_FILE = "/storage/.config/emuelec/scripts/macro_config.json"

def wait_for_controller():
    while True:
        devices = [InputDevice(path) for path in list_devices()]
        for dev in devices:
            if dev.capabilities().get(e.EV_KEY):
                keys = dev.capabilities()[e.EV_KEY]
                if any(btn in keys for btn in [e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST]):
                    return dev
        time.sleep(1)

def load_config():
    if not os.path.exists(CONFIG_FILE):
        sys.exit(1)
    with open(CONFIG_FILE, "r") as f:
        return json.load(f)

def run_macro_mode(dev, trigger_code, macro_keys):
    ui = UInput({e.EV_KEY: list(set(macro_keys))}, name="Virtual-Macro", bustype=e.BUS_USB)
    trigger_pressed = False
    macro_executed = False
    press_start = 0

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
                        ui.close()
                        return
                    elif not macro_executed:
                        for key in macro_keys:
                            ui.write(e.EV_KEY, key, 1)
                            ui.syn()
                            time.sleep(0.05)
                            ui.write(e.EV_KEY, key, 0)
                            ui.syn()

        if trigger_pressed and not macro_executed and time.time() - press_start >= 0.1:
            macro_executed = True
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
EOF
) &

echo "✅ Macro is now running in the background."
