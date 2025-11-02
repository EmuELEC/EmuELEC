#!/usr/bin/env python3
from evdev import InputDevice, list_devices, ecodes as e
import json
import os
import time
import builtins
import functools
import sys

CONFIG_FILE = "/storage/.config/emuelec/scripts/macro_config.json"
MAX_NAME_LEN = 16
NAME_ALPHABET = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_")

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(line_buffering=True, write_through=True)
    except (ValueError, OSError):
        pass

# Every print call should flush immediately so prompts appear on the EmuELEC
# console even when the script runs through a tee pipeline.
print = functools.partial(builtins.print, flush=True)


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
        e.BTN_TL: e.KEY_Q,
        e.BTN_TR: e.KEY_W,
        e.BTN_TL2: e.KEY_E,
        e.BTN_TR2: e.KEY_R,
    }
    return mapping.get(code)


def ensure_config_dir():
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)


def load_config():
    if not os.path.exists(CONFIG_FILE):
        return {"macros": []}

    with open(CONFIG_FILE, "r") as f:
        data = json.load(f)

    # migrate old single-macro configuration
    if "macros" not in data:
        macro = {
            "name": "DEFAULT MACRO",
            "trigger_code": data.get("trigger_code"),
            "macro_keys": data.get("macro_keys", []),
        }
        return {
            "device_path": data.get("device_path"),
            "macros": [macro],
        }

    return data


def save_config(data):
    ensure_config_dir()
    with open(CONFIG_FILE, "w") as f:
        json.dump(data, f, indent=2)
    print(f"\nConfiguration saved to {CONFIG_FILE}.")


def wait_for_controller(preferred_path=None):
    print("\nWaiting for controller...")

    if preferred_path:
        try:
            dev = InputDevice(preferred_path)
            print(f"Controller found: {dev.name} ({dev.path})")
            return dev
        except OSError:
            pass

    while True:
        devices = [InputDevice(path) for path in list_devices()]
        for dev in devices:
            if dev.capabilities().get(e.EV_KEY):
                keys = dev.capabilities()[e.EV_KEY]
                if any(btn in keys for btn in [e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST]):
                    print(f"Controller found: {dev.name} ({dev.path})")
                    return dev
        time.sleep(1)


def clear_console():
    print("\033[2J\033[H", end="")


def controller_menu(dev, title, options, allow_cancel=False):
    index = 0 if options else -1

    while True:
        clear_console()
        print(title)
        print("\nUse D-Pad to choose and press (A) to confirm." )
        if allow_cancel:
            print("Press (B) to cancel.")
        print()

        for i, option in enumerate(options):
            prefix = "-" if i == index else "  "
            print(f"{prefix} {option}")

        if not options:
            print("\nNo options available.")

        for event in dev.read_loop():
            if event.type != e.EV_KEY or event.value != 1:
                continue

            if event.code == e.BTN_DPAD_DOWN and options:
                index = (index + 1) % len(options)
                break
            if event.code == e.BTN_DPAD_UP and options:
                index = (index - 1) % len(options)
                break
            if event.code == e.BTN_SOUTH and options:
                return index
            if allow_cancel and event.code == e.BTN_EAST:
                return None

        # loop will refresh display after handling navigation


def enter_macro_name(dev, default_name):
    name = list(default_name.upper()[:MAX_NAME_LEN])
    if not name:
        name = list("MACRO")

    while len(name) < MAX_NAME_LEN:
        name.append(" ")

    position = 0

    while True:
        clear_console()
        print("Name your macro")
        print("\nUse LEFT/RIGHT to move, UP/DOWN to change character.")
        print("Press (A) to accept, (Y) to erase character, (B) to cancel.")
        print()

        display = []
        for idx, char in enumerate(name):
            if idx == position:
                display.append(f"[{char}]")
            else:
                display.append(f" {char} ")
        print("".join(display))

        for event in dev.read_loop():
            if event.type != e.EV_KEY or event.value != 1:
                continue

            if event.code == e.BTN_DPAD_RIGHT:
                position = min(position + 1, MAX_NAME_LEN - 1)
                break
            if event.code == e.BTN_DPAD_LEFT:
                position = max(position - 1, 0)
                break
            if event.code == e.BTN_DPAD_UP:
                current = name[position]
                try:
                    idx = NAME_ALPHABET.index(current)
                except ValueError:
                    idx = 0
                name[position] = NAME_ALPHABET[(idx + 1) % len(NAME_ALPHABET)]
                break
            if event.code == e.BTN_DPAD_DOWN:
                current = name[position]
                try:
                    idx = NAME_ALPHABET.index(current)
                except ValueError:
                    idx = 0
                name[position] = NAME_ALPHABET[(idx - 1) % len(NAME_ALPHABET)]
                break
            if event.code == e.BTN_WEST:  # Y button to clear character
                name[position] = " "
                break
            if event.code == e.BTN_SOUTH:
                final_name = "".join(name).strip()
                return final_name or default_name.upper()
            if event.code == e.BTN_EAST:
                return None


def record_trigger_button(dev):
    print("\nPress the button that will later trigger the macro...")
    while True:
        for event in dev.read_loop():
            if event.type == e.EV_KEY and event.value == 1 and event.code != e.BTN_MODE:
                print(f"Trigger button: Code {event.code}")
                time.sleep(0.5)
                return event.code


def record_macro_sequence(dev, trigger_code):
    print("\nPress the buttons for your macro. When you are finished, wait three seconds and then press any button to save and exit.")
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
        print("No buttons recorded!")
        return None

    mapped = [map_controller_to_key(c) for c in macro_keys if map_controller_to_key(c)]
    if not mapped:
        print("None of the recorded buttons can be mapped to keyboard keys!")
        return None

    print(f"Macro recorded: {len(mapped)} valid keys")
    return mapped


def main():
    config = load_config()
    dev = wait_for_controller(config.get("device_path"))

    macros = config.setdefault("macros", [])
    options = [f"Overwrite: {macro['name']}" for macro in macros]
    options.append("Create new macro")

    selection = controller_menu(dev, "🎛  Choose macro slot", options, allow_cancel=True)
    if selection is None:
        print("\nSetup cancelled.")
        return

    creating_new = selection == len(macros)

    if creating_new:
        default_name = f"MACRO {len(macros) + 1}"
        macro_name = enter_macro_name(dev, default_name)
        if macro_name is None:
            print("\nSetup cancelled.")
            return
    else:
        macro_name = macros[selection]["name"]
        print(f"\nOverwriting macro '{macro_name}'. Press the trigger to re-record.")

    trigger_code = record_trigger_button(dev)
    macro_keys = record_macro_sequence(dev, trigger_code)

    if macro_keys:
        new_macro = {
            "name": macro_name,
            "trigger_code": trigger_code,
            "macro_keys": macro_keys,
        }

        if creating_new:
            macros.append(new_macro)
        else:
            macros[selection] = new_macro

        config["device_path"] = dev.path
        save_config(config)
        print("\nSetup complete! You can choose and activate your recorded macros with Macro Enabler.")
        
    else:
        print("\nMacro recording aborted.")


if __name__ == "__main__":
    main()