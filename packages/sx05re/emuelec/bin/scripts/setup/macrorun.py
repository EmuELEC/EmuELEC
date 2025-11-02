#!/usr/bin/env python3
import sys, os, json, time, stat
from evdev import InputDevice, list_devices, ecodes as e
from evdev import UInput

CONFIG_FILE = "/storage/.config/emuelec/scripts/macro_config.json"
PID_FILE = "/tmp/macrorun.pid"
LOG_FILE = "/tmp/macrorun.log"



def load_config():
    if not os.path.exists(CONFIG_FILE):
        print("No saved configuration found. Please run Setup first!")
        sys.exit(1)
    with open(CONFIG_FILE, "r") as f:
        data = json.load(f)
    if "macros" not in data:
        data = {
            "device_path": data.get("device_path"),
            "macros": [
                {
                    "name": "DEFAULT MACRO",
                    "trigger_code": data.get("trigger_code"),
                    "macro_keys": data.get("macro_keys", []),
                }
            ],
        }
    macros = [m for m in data.get("macros", []) if m.get("macro_keys")]
    if not macros:
        print("No macros stored in configuration file. Please create one first with Setup!")
        sys.exit(1)
    data["macros"] = macros
    return data

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
        for path in list_devices():
            dev = InputDevice(path)
            if dev.capabilities().get(e.EV_KEY):
                keys = dev.capabilities()[e.EV_KEY]
                if any(btn in keys for btn in [e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST]):
                    print(f"Controller found: {dev.name} ({dev.path})")
                    return dev
        time.sleep(1)

def clear_console():
    print("\033[2J\033[H", end="")

def controller_menu(dev, title, options):
    index = 0
    while True:
        clear_console()
        print(title)
        print("\nUse D-Pad to choose a macro and press (A) to confirm.")
        print("Press (B) to cancel and exit.\n")
        for i, option in enumerate(options):
            prefix = "->" if i == index else "  "
            print(f"{prefix} {option}")
        for event in dev.read_loop():
            if event.type != e.EV_KEY or event.value != 1:
                continue
            if event.code == e.BTN_DPAD_DOWN:
                index = (index + 1) % len(options); break
            if event.code == e.BTN_DPAD_UP:
                index = (index - 1) % len(options); break
            if event.code == e.BTN_SOUTH:
                return index
            if event.code == e.BTN_EAST:
                print("\nMacro activation cancelled.")
                sys.exit(0)

def run_macro_mode(dev, macro):
    trigger_code = macro["trigger_code"]
    macro_keys = macro["macro_keys"]
    ui = UInput({e.EV_KEY: list(set(macro_keys))}, name="Virtual-Macro", bustype=e.BUS_USB)
    trigger_pressed = False
    macro_executed = False
    press_start = 0
    print("\nMacro active! Press the trigger to execute. Hold for 3 seconds to disable Macro again.")
    for event in dev.read_loop():
        if event.type == e.EV_KEY and event.code == trigger_code:
            if event.value == 1:
                trigger_pressed = True
                macro_executed = False
                press_start = time.time()
            elif event.value == 0 and trigger_pressed:
                hold_time = time.time() - press_start
                trigger_pressed = False
                if hold_time >= 3:
                    print("Exiting...")
                    ui.close()
                    return
                elif not macro_executed:
                    print("Executing macro...")
                    for key in macro_keys:
                        ui.write(e.EV_KEY, key, 1); ui.syn(); time.sleep(0.05)
                        ui.write(e.EV_KEY, key, 0); ui.syn()
        if trigger_pressed and not macro_executed and time.time() - press_start >= 0.1:
            macro_executed = True
            print("Executing macro...")
            for key in macro_keys:
                ui.write(e.EV_KEY, key, 1); ui.syn(); time.sleep(0.05)
                ui.write(e.EV_KEY, key, 0); ui.syn()

def already_running():
    try:
        with open(PID_FILE) as f:
            pid = int(f.read().strip())
        os.kill(pid, 0)
        return True
    except Exception:
        return False

def daemonize(dev_path, macro):
   
    try:
        if os.fork() > 0:
            return 0  
        os.setsid()
        if os.fork() > 0:
            os._exit(0)
    except OSError:
        return 2

    
    try:
        sys.stdin.close()
    except Exception:
        pass
    try:
        log = open(LOG_FILE, "ab", buffering=0)
    except OSError:
        log = open("/dev/null", "ab", buffering=0)
    for fd in (1, 2):
        try:
            os.dup2(log.fileno(), fd)
        except OSError:
            pass

    
    try:
        with open(PID_FILE, "w") as pf:
            pf.write(str(os.getpid()))
    except OSError:
        pass

    
    try:
        dev = InputDevice(dev_path)
        run_macro_mode(dev, macro)
    finally:
        try:
            os.remove(PID_FILE)
        except OSError:
            pass
    os._exit(0)

def main():
    if already_running():
        print("Macro already running. Aborting.")
        return 0

    cfg = load_config()
    macros = cfg["macros"]
    dev = wait_for_controller(cfg.get("device_path"))
    option_labels = [f"{m['name']} (Trigger {m['trigger_code']})" for m in macros]
    selection = controller_menu(dev, "Select macro to activate", option_labels)
    chosen_macro = macros[selection]

    print("\nStarting macro in background...")
    rc = daemonize(dev.path, chosen_macro)
    if rc == 0:
        print("Macro is now running in the background. Exiting to Emulationstation...")
        return 0
    else:
        print("Macro could not be started in the background.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
