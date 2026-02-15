#!/usr/bin/env python3
"""EmuELEC MAME .cmd batch generator (controller UI)."""
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

import os
import glob
import re
import shutil
import xml.etree.ElementTree as ET
from typing import Dict, List, Tuple, Optional
import sys
import struct
import select
import time
from evdev import InputDevice, list_devices, ecodes as e


class MediaEntry:
    def __init__(self, system: str, media_name: str, brief: str, exts: List[str]):
        self.system = system
        self.media_name = media_name
        self.brief = brief
        self.exts = exts


DEFAULT_LISTMEDIA_FILE = "/storage/roms/listmedia.txt"
SYSTEM_LISTMEDIA_FILE = "/usr/bin/scripts/setup/listmedia.txt"
ROM_PLACEHOLDER = "<ROM_PATH>"

# Linux input event codes
EV_KEY = 1
EV_ABS = 3

# Button codes (common gamepad mapping)
BTN_SOUTH = 304  # A/Cross
BTN_EAST = 305   # B/Circle
BTN_WEST = 306   # X/Square
BTN_NORTH = 307  # Y/Triangle
BTN_TL = 308     # L1
BTN_TR = 309     # R1
BTN_SELECT = 314 # Select/Back
BTN_START = 315  # Start
BTN_MODE = 316   # Home/Guide

# D-Pad absolute axes
ABS_HAT0X = 16
ABS_HAT0Y = 17

# Keyboard codes
KEY_UP = 103
KEY_DOWN = 108
KEY_LEFT = 105
KEY_RIGHT = 106
KEY_ENTER = 28
KEY_ESC = 1
KEY_BACKSPACE = 14
KEY_Q = 16

# Character set for command line editor
CMD_ALPHABET = list("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -_./\\()[]{}\"'=:,;")
MAX_CMD_LEN = 256


class UserQuit(Exception):
    pass


class GoBack(Exception):
    pass


def find_controller_device() -> str:
    patterns = re.compile(r"(pad|controller|joystick|xbox|playstation|ps[0-9]|dualshock|dualsense|8bitdo)", re.I)

    # Collect candidates: (priority, path, name)
    candidates = []
    for path in sorted(glob.glob("/dev/input/event*")):
        base = os.path.basename(path)
        name_path = f"/sys/class/input/{base}/device/name"
        devname = ""
        try:
            with open(name_path, "r", encoding="utf-8", errors="ignore") as f:
                devname = f.read().strip()
        except Exception:
            devname = ""

        priority = 0 if (devname and patterns.search(devname)) else 1
        candidates.append((priority, path, devname))

    # Try preferred candidates first
    for _, path, devname in sorted(candidates, key=lambda t: (t[0], t[1])):
        try:
            with open(path, "rb") as _f:
                pass
            if devname:
                print(f"Auto-detected controller: {devname} ({path})", flush=True)
            else:
                print(f"Auto-detected input device: {path}", flush=True)
            return path
        except Exception:
            continue

    print("Warning: No /dev/input/event* device could be opened; falling back to /dev/input/event0", flush=True)
    return "/dev/input/event0"

# ---------------------------------------------------------------------------
# Controller Input Handling
# ---------------------------------------------------------------------------

class ControllerInput:

    def __init__(self, preferred_path: Optional[str] = None):
        self.dev = wait_for_controller(preferred_path)
        self.last_hat_x = 0
        self.last_hat_y = 0

    def wait_for_input(self) -> str:
        for event in self.dev.read_loop():
            # Button presses
            if event.type == e.EV_KEY and event.value == 1:
                code = event.code

                # D-Pad (digital)
                if code == e.BTN_DPAD_UP:
                    return 'up'
                if code == e.BTN_DPAD_DOWN:
                    return 'down'
                if code == e.BTN_DPAD_LEFT:
                    return 'left'
                if code == e.BTN_DPAD_RIGHT:
                    return 'right'

                # Confirm / Back
                if code in (e.BTN_SOUTH, e.BTN_START):
                    return 'a'
                if code == e.BTN_EAST:
                    return 'b'

                # Additional buttons
                if code == e.BTN_NORTH:
                    return 'y'
                if code == e.BTN_WEST:
                    return 'x'
                if code == e.BTN_TL:
                    return 'l1'
                if code == e.BTN_TR:
                    return 'r1'

                # Quit / special
                if code in (e.BTN_SELECT, e.BTN_MODE):
                    return 'select'

                # Some controllers map D-pad to face buttons/keys; keep a small fallback
                if code in (e.KEY_UP,):
                    return 'up'
                if code in (e.KEY_DOWN,):
                    return 'down'
                if code in (e.KEY_LEFT,):
                    return 'left'
                if code in (e.KEY_RIGHT,):
                    return 'right'
                if code in (e.KEY_ENTER,):
                    return 'a'
                if code in (e.KEY_ESC, e.KEY_BACKSPACE):
                    return 'b'

            # D-Pad (hat axes)
            if event.type == e.EV_ABS:
                if event.code == e.ABS_HAT0Y:
                    if event.value < 0 and self.last_hat_y >= 0:
                        self.last_hat_y = event.value
                        return 'up'
                    if event.value > 0 and self.last_hat_y <= 0:
                        self.last_hat_y = event.value
                        return 'down'
                    if event.value == 0:
                        self.last_hat_y = 0

                if event.code == e.ABS_HAT0X:
                    if event.value < 0 and self.last_hat_x >= 0:
                        self.last_hat_x = event.value
                        return 'left'
                    if event.value > 0 and self.last_hat_x <= 0:
                        self.last_hat_x = event.value
                        return 'right'
                    if event.value == 0:
                        self.last_hat_x = 0

    def close(self):
        try:
            self.dev.close()
        except Exception:
            pass


def wait_for_controller(preferred_path: Optional[str] = None) -> InputDevice:
    print("\nWaiting for controller...", flush=True)

    if preferred_path:
        try:
            dev = InputDevice(preferred_path)
            print(f"Controller found: {dev.name} ({dev.path})", flush=True)
            return dev
        except OSError:
            pass

    while True:
        for path in list_devices():
            try:
                dev = InputDevice(path)
            except OSError:
                continue

            caps = dev.capabilities()
            keys = caps.get(e.EV_KEY, [])
            abs_caps = caps.get(e.EV_ABS, [])

            # Heuristic: real gamepad usually has face buttons and/or dpad
            has_face = any(btn in keys for btn in (e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST))
            has_dpad = any(btn in keys for btn in (e.BTN_DPAD_UP, e.BTN_DPAD_DOWN, e.BTN_DPAD_LEFT, e.BTN_DPAD_RIGHT))
            has_hat = any(ax in abs_caps for ax in (e.ABS_HAT0X, e.ABS_HAT0Y))

            if has_face or has_dpad or has_hat:
                print(f"Controller found: {dev.name} ({dev.path})", flush=True)
                return dev

        time.sleep(1.0)


def init_controller(preferred_path: Optional[str] = None):
    global controller
    controller = ControllerInput(preferred_path)

def unblank_framebuffer() -> None:
    for p in ("/sys/class/graphics/fb0/blank", "/sys/class/graphics/fb1/blank"):
        try:
            with open(p, "w", encoding="utf-8") as f:
                f.write("0")
        except Exception:
            pass

def clear_screen():
    unblank_framebuffer()
    print("\033[2J\033[H", end='', flush=True)


def show_menu(
    title: str,
    options: List[str],
    selected: int = 0,
    info: str = "",
    offset: int = 0,
    visible: int = 20,
    show_items: bool = False,
) -> None:
    """Render the menu."""
    clear_screen()
    print("=" * 98)
    print(f" {title}")
    print("=" * 98)

    total = len(options)
    if visible <= 0:
        visible = total

    # Clamp offset
    if offset < 0:
        offset = 0
    if offset > max(0, total - 1):
        offset = max(0, total - 1)

    start = offset
    end = min(offset + visible, total)
    
    if info:
        print(f"\n\n\n{info}\n")

    for i in range(start, end):
        option = options[i]
        if i == selected:
            print(f"  > {option}")
        else:
            print(f"    {option}")

    if end < total:
        print("    ...")

    print("\n" + "-" * 98)
    print("D-Pad: Navigate | A: Select | B: Back | Select: Quit | Left/Right: Page up/down")
    print("-" * 98)
    sys.stdout.flush()

def select_from_list(title: str, items: List[str], info: str = "", visible: int = 20, show_items: bool = False) -> Optional[int]:
    if not items:
        return None

    total = len(items)
    selected = 0
    offset = 0

    # Ensure sensible visible window
    if visible <= 0:
        visible = total

    while True:
        # Keep selected visible
        if selected < offset:
            offset = selected
        elif selected >= offset + visible:
            offset = selected - visible + 1

        # Clamp offset to valid range
        if total > visible:
            max_off = max(0, total - visible)
            if offset > max_off:
                offset = max_off
        else:
            offset = 0

        show_menu(title, items, selected, info, offset=offset, visible=visible)

        key = controller.wait_for_input()

        if key == 'select':
            raise UserQuit()

        elif key == 'up':
            if selected > 0:
                selected -= 1

        elif key == 'down':
            if selected < total - 1:
                selected += 1

        elif key == 'left':
            # Page up
            selected = max(0, selected - visible)

        elif key == 'right':
            # Page down
            selected = min(total - 1, selected + visible)

        elif key == 'a':
            return selected

        elif key == 'b':
            raise GoBack()


def confirm_dialog(title: str, message: str, default_yes: bool = True) -> bool:
    options = ["Yes", "No"]
    selected = 0 if default_yes else 1
    
    while True:
        show_menu(title, options, selected, message)
        
        key = controller.wait_for_input()
        
        if key == 'select':
            raise UserQuit()
        
        elif key in ['up', 'down']:
            selected = 1 - selected
        
        elif key == 'a':
            return selected == 0
        
        elif key == 'b':
            return False


def ok_dialog(title: str, message: str) -> None:
    options = ["OK"]
    selected = 0
    while True:
        show_menu(title, options, selected, message, 0, 20, False)
        key = controller.wait_for_input()
        if key == 'select':
            raise UserQuit()
        if key in ['a', 'b', 'start']:
            return


def back_exit_dialog(title: str, message: str) -> str:
    options = ["B A C K", "E X I T"]
    selected = 0
    while True:
        show_menu(title, options, selected, message, 0, 20, False)
        key = controller.wait_for_input()
        if key == 'select':
            raise UserQuit()
        if key in ['up', 'down']:
            selected = 1 - selected
        if key in ['b']:
            return "back"
        if key in ['a', 'start']:
            return "back" if selected == 0 else "exit"


# ---------------------------------------------------------------------------
# Custom Command Line Editor
# ---------------------------------------------------------------------------

def edit_command_line(default_cmd: str) -> Optional[str]:

    # Prepare the command as a list of characters
    cmd = list(default_cmd[:MAX_CMD_LEN])
    if not cmd:
        cmd = list("mame ")
    
    # Pad to minimum length for easier editing
    while len(cmd) < 20:
        cmd.append(" ")
    
    position = 0
    view_offset = 0  # For horizontal scrolling
    view_width = 80  # Visible characters at once
    
    while True:
        clear_screen()
        print("=" * 98)
        print(" Edit Command Line")
        print("=" * 98)
        print()
        print("LEFT/RIGHT: Move cursor | UP/DOWN: Change character")
        print("L1/R1: Jump 10 chars | X: Insert space | Y: Delete char")
        print("A: Accept | B: Cancel")
        print()
        print("-" * 98)
        
        # Adjust view offset to keep cursor visible
        if position < view_offset:
            view_offset = position
        elif position >= view_offset + view_width:
            view_offset = position - view_width + 1
        
        # Create visible window
        visible_start = view_offset
        visible_end = min(view_offset + view_width, len(cmd))
        
        # Build display with cursor
        display = []
        for idx in range(visible_start, visible_end):
            char = cmd[idx] if idx < len(cmd) else " "
            if idx == position:
                display.append(f"[{char}]")
            else:
                display.append(f" {char} ")
        
        # Show scroll indicators
        left_indicator = "<" if view_offset > 0 else " "
        right_indicator = ">" if visible_end < len(cmd) else " "
        
        print(f"{left_indicator}{''.join(display)}{right_indicator}")
        print()
        print(f"Position: {position + 1}/{len(cmd)} | Length: {len(cmd)}/{MAX_CMD_LEN}")
        print("-" * 98)
        
        # Get current command preview
        current_cmd = ''.join(cmd).rstrip()
        if len(current_cmd) > 90:
            preview = current_cmd[:87] + "..."
        else:
            preview = current_cmd
        print(f"Preview: {preview}")
        print("=" * 98)
        sys.stdout.flush()
        
        key = controller.wait_for_input()
        
        if key == 'select':
            raise UserQuit()
        
        elif key == 'right':
            if position < len(cmd) - 1:
                position += 1
        
        elif key == 'left':
            if position > 0:
                position -= 1
        
        elif key == 'r1':  # Jump right
            position = min(position + 10, len(cmd) - 1)
        
        elif key == 'l1':  # Jump left
            position = max(position - 10, 0)
        
        elif key == 'up':
            # Next character in alphabet
            current = cmd[position]
            try:
                idx = CMD_ALPHABET.index(current)
            except ValueError:
                idx = 0
            cmd[position] = CMD_ALPHABET[(idx + 1) % len(CMD_ALPHABET)]
        
        elif key == 'down':
            # Previous character in alphabet
            current = cmd[position]
            try:
                idx = CMD_ALPHABET.index(current)
            except ValueError:
                idx = 0
            cmd[position] = CMD_ALPHABET[(idx - 1) % len(CMD_ALPHABET)]
        
        elif key == 'x':
            # Insert space at current position
            if len(cmd) < MAX_CMD_LEN:
                cmd.insert(position, ' ')
        
        elif key == 'y':
            # Delete character at current position
            if len(cmd) > 1:
                cmd.pop(position)
                if position >= len(cmd):
                    position = len(cmd) - 1
        
        elif key == 'a':
            # Accept
            final_cmd = ''.join(cmd).strip()
            if not final_cmd:
                continue
            # Ensure ROM placeholder is present
            if ROM_PLACEHOLDER not in final_cmd:
                ok_dialog("Missing Placeholder", 
                         f"Command must contain {ROM_PLACEHOLDER}\n\nThis will be replaced with the ROM path.")
                continue
            return final_cmd
        
        elif key == 'b':
            # Cancel
            return None


def ask_file_filter(default_exts: List[str]) -> List[str]:
    exts = [e.lower() for e in (default_exts or [])]
    if ".zip" not in exts:
        exts.append(".zip")

    if not exts:
        return []

    ext_str = " ".join(exts[:8])
    if len(exts) > 8:
        ext_str += f" ... (+{len(exts)-8})"

    use_filter = confirm_dialog(
        "File Filter",
        f"Filter by these file types?\n\n{ext_str}",
        True
    )
    if use_filter:
        return exts

    options = ["All files (no filter)"] + exts
    choice = select_from_list("Pick one file type", options, visible=20)
    if choice is None:
        raise GoBack()
    if choice == 0:
        return []
    return [exts[choice - 1]]

def _read_listmedia_text(path: str) -> str:
    with open(path, "rb") as bf:
        data = bf.read()

    if b"\x00" in data[:4096]:
        try:
            return data.decode("utf-16")
        except UnicodeError:
            return data.decode("utf-16-le", errors="ignore")
    else:
        return data.decode("utf-8", errors="ignore")


def parse_listmedia(path: str) -> Dict[str, List[MediaEntry]]:
    if not os.path.isfile(path):
        raise FileNotFoundError(f"Listmedia file not found: {path}")

    text = _read_listmedia_text(path)
    systems: Dict[str, List[MediaEntry]] = {}
    current_system: Optional[str] = None

    for line in text.splitlines():
        original = line.rstrip("\r\n")
        stripped = original.strip()
        if not stripped:
            continue

        tokens = stripped.split()
        if len(tokens) == 2 and tokens[1].startswith("(none"):
            continue

        if len(tokens) < 3:
            continue

        brief_idx = None
        for i, t in enumerate(tokens):
            if t.startswith("(") and t.endswith(")"):
                brief_idx = i
                break
        if brief_idx is None or brief_idx == 0:
            continue

        is_continuation = bool(original) and original[0].isspace()

        if is_continuation:
            if current_system is None:
                continue
            system = current_system
            media_name = tokens[0]
        else:
            system = tokens[0]
            current_system = system
            if brief_idx >= 2:
                media_name = tokens[1]
            else:
                continue

        brief = tokens[brief_idx].strip("()")
        exts = [t for t in tokens[brief_idx + 1:] if t.startswith(".")]

        entry = MediaEntry(system, media_name, brief, exts)
        systems.setdefault(system, []).append(entry)

    return systems


# ---------------------------------------------------------------------------
# System selection
# ---------------------------------------------------------------------------

def browse_systems_paged(all_systems: List[str], page_size: int = 20) -> Optional[str]:
    if not all_systems:
        return None

    info = f"Total systems: {len(all_systems)}"
    idx = select_from_list("Select System", all_systems, info, visible=page_size, show_items=True)
    if idx is None:
        return None
    return all_systems[idx]


def choose_system(systems: Dict[str, List[MediaEntry]]) -> str:
    all_systems = sorted(systems.keys())
    
    while True:
        options = [
            "Browse System List",
            "Back to Main Menu"
        ]
        
        try:
            idx = select_from_list(
                "System Selection",
                options,
                f"{len(all_systems)} systems available"
            )
            
            if idx is None or idx == 1:
                raise GoBack()
            
            if idx == 0:
                selected = browse_systems_paged(all_systems)
                if selected:
                    return selected
                
        except GoBack:
            raise


def choose_media(entries: List[MediaEntry]) -> MediaEntry:
    options = []
    for e in entries:
        exts_str = " ".join(e.exts[:3]) if e.exts else ""
        options.append(f"{e.media_name} ({e.brief}) {exts_str}")
    
    idx = select_from_list("Select Media Type", options)
    
    if idx is None:
        raise GoBack()
    
    return entries[idx]


# ---------------------------------------------------------------------------
# Directory selection
# ---------------------------------------------------------------------------

def choose_directory_interactive(prompt: str, start_dir: str = "/storage/roms") -> str:
    current = os.path.abspath(start_dir)

    while True:
        try:
            entries = os.listdir(current)
            subdirs = sorted(
                d for d in entries
                if os.path.isdir(os.path.join(current, d)) and not d.startswith('.')
            )
        except Exception:
            subdirs = []

        options: List[str] = ["[Use This Directory]"]
        if current != "/":
            options.append("[.. Parent Directory]")
        options.extend(subdirs)

        info = f"Current: {current}"
        idx = select_from_list(prompt, options, info, visible=20, show_items=True)
        if idx is None:
            raise GoBack()

        selected = options[idx]

        if selected == "[Use This Directory]":
            return current
        elif selected == "[.. Parent Directory]":
            parent = os.path.dirname(current)
            if parent and parent != current:
                current = parent
        else:
            current = os.path.join(current, selected)


def ask_directory_and_filter(default_exts: List[str]) -> Tuple[str, List[str]]:
    rom_dir = choose_directory_interactive("Select ROM Directory", "/storage/roms")

    exts = [e.lower() for e in (default_exts or [])]
    if ".zip" not in exts:
        exts.append(".zip")

    if exts:
        ext_str = " ".join(exts[:8])
        if len(exts) > 8:
            ext_str += f" ... (+{len(exts)-8})"

        use_filter = confirm_dialog(
            "File Filter",
            f"Filter by these file types?\n\n{ext_str}",
            True
        )

        if use_filter:
            return rom_dir, exts

        options = ["All files (no filter)"] + exts
        choice = select_from_list("Pick one file type", options, visible=20)
        if choice is None or choice == 0:
            return rom_dir, []
        return rom_dir, [exts[choice - 1]]

    return rom_dir, []


def find_rom_files(rom_dir: str, exts: List[str]) -> List[str]:
    files: List[str] = []
    try:
        for name in os.listdir(rom_dir):
            full = os.path.join(rom_dir, name)
            if not os.path.isfile(full):
                continue
            if exts:
                _, ext = os.path.splitext(name)
                if ext.lower() not in exts:
                    continue
            if name.lower().endswith(".cmd"):
                continue
            files.append(name)
    except:
        pass
    return sorted(files)


# ---------------------------------------------------------------------------
# Templates
# ---------------------------------------------------------------------------

def build_default_template_preset(system: str, media: MediaEntry, extra_options: str) -> str:
    parts = [system, "-rp /storage/roms/bios"]
    extra_options = extra_options.strip()
    if extra_options:
        parts.append(extra_options)
    parts.append(f"-{media.brief} \"{ROM_PLACEHOLDER}\"")
    return " ".join(parts)


def apply_template(template: str, rom_path: str) -> str:
    return template.replace(ROM_PLACEHOLDER, rom_path)


# ---------------------------------------------------------------------------
# Per-file review
# ---------------------------------------------------------------------------

def review_cmd(cmd_path: str, cmd_line: str, accept_all: bool) -> Tuple[Optional[str], bool, bool]:
    if accept_all:
        return cmd_line, True, True

    options = [
        "CREATE .CMD-FILE FOR THIS ROM",
        "SKIP THIS ROM",
        "CREATE .CMD-FILES FOR ALL SELECTED ROMS",
        "BACK"
    ]
    
    display_path = cmd_path
    if len(display_path) > 65:
        display_path = "..." + display_path[-62:]
    
    display_cmd = cmd_line
    if len(display_cmd) > 68:
        display_cmd = display_cmd[:65] + "..."
    
    info = f"File: {display_path}\n\nThe command line in the .cmd files will be:\n{display_cmd}"
    
    try:
        idx = select_from_list("Create .cmd File", options, info)
        
        if idx is None or idx == 3:
            raise GoBack()
        
        if idx == 0:
            return cmd_line, True, False
        
        if idx == 2:
            return cmd_line, True, True
        
        # idx == 1: Skip
        return None, False, False
        
    except GoBack:
        raise


# ---------------------------------------------------------------------------
# Write .cmd
# ---------------------------------------------------------------------------

def write_cmd_file(cmd_path: str, cmd_line: str) -> None:
    os.makedirs(os.path.dirname(cmd_path), exist_ok=True)
    with open(cmd_path, "w", encoding="utf-8") as f:
        f.write(cmd_line)
        f.write("\n")


# ---------------------------------------------------------------------------
# gamelist.xml update
# ---------------------------------------------------------------------------

def update_gamelist_paths(gamelist_path: str, rom_dir: str, rom_files: List[str]) -> int:
    if not os.path.isfile(gamelist_path):
        return 0

    base_names = {os.path.splitext(name)[0] for name in rom_files}

    try:
        tree = ET.parse(gamelist_path)
        root = tree.getroot()
    except:
        return 0

    changed = 0

    for path_elem in root.iter("path"):
        text = path_elem.text or ""
        original = text.strip()
        if not original:
            continue

        old_basename = os.path.basename(original)
        base, ext = os.path.splitext(old_basename)
        if base not in base_names:
            continue
        if ext.lower() == ".cmd":
            continue

        new_basename = base + ".cmd"
        new_text = original[:-len(old_basename)] + new_basename
        path_elem.text = new_text
        changed += 1

    if changed > 0:
        backup_path = gamelist_path + ".bak"
        try:
            shutil.copy2(gamelist_path, backup_path)
            tree.write(gamelist_path, encoding="utf-8", xml_declaration=True)
        except:
            return 0

    return changed


def maybe_update_gamelist(rom_dir: str, rom_files: List[str]) -> None:
    if not rom_files:
        return

    update = confirm_dialog(
        "Update gamelist.xml",
        "Update gamelist.xml paths to use .cmd files?",
        False
    )

    default_gamelist = os.path.join(rom_dir, "gamelist.xml")

    if not update:
        ok_dialog("Gamelist.xml", "Gamelist.xml update was skipped.")
        return

    if not os.path.isfile(default_gamelist):
        ok_dialog("Gamelist.xml", "gamelist.xml not found; no changes made.")
        return

    changed = update_gamelist_paths(default_gamelist, rom_dir, rom_files)

    if changed > 0:
        ok_dialog("Success", f"Updated {changed} entries in gamelist.xml")
    else:
        ok_dialog("Gamelist.xml", "No matching entries were updated.")


# ---------------------------------------------------------------------------
# Preset Mode
# ---------------------------------------------------------------------------

def run_preset_mode(systems: Dict[str, List[MediaEntry]]) -> None:
    system: Optional[str] = None
    media: Optional[MediaEntry] = None
    rom_dir: Optional[str] = None
    exts: List[str] = []
    rom_files: List[str] = []

    step = 0  # 0=system, 1=media, 2=dir, 3=filter, 4=process

    while True:
        if step == 0:
            system = choose_system(systems)
            media = None
            rom_dir = None
            exts = []
            rom_files = []
            step = 1
            continue

        if step == 1:
            try:
                media = choose_media(systems[system])  # type: ignore[index]
                step = 2
            except GoBack:
                step = 0
            continue

        if step == 2:
            try:
                rom_dir = choose_directory_interactive("Select ROM Directory", "/storage/roms")
                step = 3
            except GoBack:
                step = 1
            continue

        if step == 3:
            try:
                while True:
                    exts = ask_file_filter(media.exts if media else [])  # type: ignore[union-attr]
                    rom_files = find_rom_files(rom_dir, exts)  # type: ignore[arg-type]
                    if rom_files:
                        break

                    action = back_exit_dialog(
                        "No Files Found",
                        f"No ROM files found in:\n{rom_dir}\n\nSelect BACK to adjust the file filter, or EXIT to quit."
                    )
                    if action == "exit":
                        raise UserQuit()
                    # BACK: loop back to filter selection

                ok_dialog("Files Found", f"Found {len(rom_files)} ROM file(s) that will be processed.")
                step = 4
            except GoBack:
                step = 2
            continue

        # step == 4: Process files with preset template
        template = build_default_template_preset(system, media, "")  # type: ignore[arg-type]
            
        accept_all = False
        created_for_gamelist: List[str] = []

        i = 0
        while i < len(rom_files):
            name = rom_files[i]
            rom_path = os.path.join(rom_dir, name)  # type: ignore[arg-type]
            cmd_line = apply_template(template, rom_path)

            cmd_path = os.path.join(rom_dir, os.path.splitext(name)[0] + ".cmd")  # type: ignore[arg-type]

            try:
                selected_cmd, accepted, accept_all = review_cmd(cmd_path, cmd_line, accept_all)
            except GoBack:
                # Go back to file filter selection
                step = 3
                break

            if not accepted or not selected_cmd:
                i += 1
                continue

            try:
                write_cmd_file(cmd_path, selected_cmd)
                created_for_gamelist.append(name)
            except Exception as e:
                ok_dialog("Write Error", f"Failed to write:\n{cmd_path}\n\n{e}")
            i += 1

        if step == 3:
            continue

        if created_for_gamelist:
            maybe_update_gamelist(rom_dir, created_for_gamelist)  # type: ignore[arg-type]

        ok_dialog("Completed", f"Created {len(created_for_gamelist)} .cmd files")
        return


def run_custom_mode() -> None:
    rom_dir: Optional[str] = None
    exts: List[str] = []
    rom_files: List[str] = []
    custom_template: Optional[str] = None

    step = 0  # 0=create_command, 1=dir, 2=filter, 3=process

    while True:
        if step == 0:
            # Create custom command
            try:
                default_cmd = f"mame -rp /storage/roms/bios -cdrom \"{ROM_PLACEHOLDER}\""
                
                options = [
                    "Create Custom Command",
                    "Back to Main Menu"
                ]
                
                info = "Create a custom command line for your ROM files.\n\nThe command will be used for all selected ROMs."
                
                idx = select_from_list("Custom Mode", options, info)
                
                if idx is None or idx == 1:
                    raise GoBack()
                
                if idx == 0:
                    edited = edit_command_line(default_cmd)
                    if edited is None:
                        continue
                    
                    # Show confirmation
                    preview = edited if len(edited) <= 80 else edited[:77] + "..."
                    confirm = confirm_dialog(
                        "Confirm Custom Command",
                        f"Use this command for all ROMs?\n\n{preview}",
                        True
                    )
                    
                    if confirm:
                        custom_template = edited
                        step = 1
                    else:
                        continue
                        
            except GoBack:
                raise
            continue

        if step == 1:
            try:
                rom_dir = choose_directory_interactive("Select ROM Directory", "/storage/roms")
                step = 2
            except GoBack:
                step = 0
            continue

        if step == 2:
            try:
                while True:
                    # Scan directory for available file extensions
                    available_exts = set()
                    try:
                        for name in os.listdir(rom_dir):  # type: ignore[arg-type]
                            full = os.path.join(rom_dir, name)  # type: ignore[arg-type]
                            if not os.path.isfile(full):
                                continue
                            if name.lower().endswith(".cmd"):
                                continue
                            _, ext = os.path.splitext(name)
                            if ext:
                                available_exts.add(ext.lower())
                    except Exception:
                        available_exts = {".zip", ".chd", ".cue", ".iso", ".bin"}
                    
                    # Build options list
                    options = ["All files (no filter)"]
                    sorted_exts = sorted(available_exts)
                    options.extend(sorted_exts)
                    
                    info = f"Found {len(available_exts)} file types in directory"
                    choice = select_from_list("Pick file type filter", options, info, visible=20)
                    
                    if choice is None:
                        raise GoBack()
                    
                    if choice == 0:
                        exts = []
                    else:
                        exts = [sorted_exts[choice - 1]]
                    
                    rom_files = find_rom_files(rom_dir, exts)  # type: ignore[arg-type]
                    if rom_files:
                        break

                    action = back_exit_dialog(
                        "No Files Found",
                        f"No ROM files found in:\n{rom_dir}\n\nSelect BACK to adjust the file filter, or EXIT to quit."
                    )
                    if action == "exit":
                        raise UserQuit()

                ok_dialog("Files Found", f"Found {len(rom_files)} ROM file(s) that will be processed.")
                step = 3
            except GoBack:
                step = 1
            continue

        # step == 3: Process files with custom template
        if not custom_template:
            step = 0
            continue
            
        accept_all = False
        created_for_gamelist: List[str] = []

        i = 0
        while i < len(rom_files):
            name = rom_files[i]
            rom_path = os.path.join(rom_dir, name)  # type: ignore[arg-type]
            cmd_line = apply_template(custom_template, rom_path)

            cmd_path = os.path.join(rom_dir, os.path.splitext(name)[0] + ".cmd")  # type: ignore[arg-type]

            try:
                selected_cmd, accepted, accept_all = review_cmd(cmd_path, cmd_line, accept_all)
            except GoBack:
                step = 2
                break

            if not accepted or not selected_cmd:
                i += 1
                continue

            try:
                write_cmd_file(cmd_path, selected_cmd)
                created_for_gamelist.append(name)
            except Exception as e:
                ok_dialog("Write Error", f"Failed to write:\n{cmd_path}\n\n{e}")
            i += 1

        if step == 2:
            continue

        if created_for_gamelist:
            maybe_update_gamelist(rom_dir, created_for_gamelist)  # type: ignore[arg-type]

        ok_dialog("Completed", f"Created {len(created_for_gamelist)} .cmd files")
        return


def main() -> None:
    # EmulationStation may launch this script without a real TTY on stdin.
    # Only enable raw terminal mode when stdin is a TTY (e.g. when run via SSH).
    try:
        # Initialize controller (auto-detect; no argument required)
        preferred_path = sys.argv[1] if len(sys.argv) > 1 else None
        init_controller(preferred_path)
        
        clear_screen()
        print("Initializing CMD Maker...", flush=True)
        time.sleep(0.5)
        
        systems: Dict[str, List[MediaEntry]] = {}
        
        # Check which listmedia files are available
        user_listmedia_exists = os.path.exists(DEFAULT_LISTMEDIA_FILE)
        system_listmedia_exists = os.path.exists(SYSTEM_LISTMEDIA_FILE)
        
        list_path = None
        
        # If both exist, let user choose
        if user_listmedia_exists and system_listmedia_exists:
            try:
                options = [
                    f"User listmedia.txt ({DEFAULT_LISTMEDIA_FILE})",
                    f"System listmedia.txt ({SYSTEM_LISTMEDIA_FILE})"
                ]
                
                idx = select_from_list(
                    "Choose listmedia.txt",
                    options,
                    "Multiple listmedia.txt files found"
                )
                
                if idx == 0:
                    list_path = DEFAULT_LISTMEDIA_FILE
                elif idx == 1:
                    list_path = SYSTEM_LISTMEDIA_FILE
                    
            except (GoBack, UserQuit):
                pass
        
        # Otherwise use whichever exists
        elif user_listmedia_exists:
            list_path = DEFAULT_LISTMEDIA_FILE
            print(f"Using user listmedia.txt", flush=True)
            time.sleep(0.3)
        elif system_listmedia_exists:
            list_path = SYSTEM_LISTMEDIA_FILE
            print(f"Using system listmedia.txt", flush=True)
            time.sleep(0.3)
        
        # Try to load listmedia.txt
        if list_path:
            try:
                systems = parse_listmedia(list_path)
                print(f"Loaded {len(systems)} systems from {os.path.basename(list_path)}", flush=True)
                time.sleep(0.5)
            except Exception as e:
                print(f"Warning: Could not load listmedia.txt: {e}", flush=True)
                time.sleep(1)

        try:
            while True:
                try:
                    options = [
                        f"Preset Mode ({len(systems)} systems)",
                        "Custom Mode",
                        "Exit"
                    ]
                    
                    idx = select_from_list(
                        "C M D  M A K E R",
                        options,
                        "Create .cmd files for MAME ROMs"
                    )
                    
                    if idx is None or idx == 2:
                        break
                    
                    if idx == 0:
                        if not systems:
                            ok_dialog(
                                "No Presets", 
                                f"No listmedia.txt found in:\n{DEFAULT_LISTMEDIA_FILE}\nor\n{SYSTEM_LISTMEDIA_FILE}"
                            )
                        else:
                            try:
                                run_preset_mode(systems)
                            except GoBack:
                                continue
                    
                    elif idx == 1:
                        try:
                            run_custom_mode()
                        except GoBack:
                            continue
                
                except GoBack:
                    continue
        
        except UserQuit:
            pass
        except KeyboardInterrupt:
            pass
        finally:
            clear_screen()
            print("Exiting CMD Maker...", flush=True)
            time.sleep(0.5)
            
            if controller:
                controller.close()
    
    finally:
        pass


if __name__ == "__main__":
    main()