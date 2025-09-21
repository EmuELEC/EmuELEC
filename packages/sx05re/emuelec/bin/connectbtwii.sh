#!/bin/sh
""":"
# Shell part: stop the eventlircd service and re-execute this script with Python3
/usr/bin/systemctl stop eventlircd
exec python3 "$0" "$@"
"""
# Python code starts here
import subprocess
import re
import sys
import time

def run_bluetoothctl_command(cmd):
    """Executes a bluetoothctl command and returns its output."""
    result = subprocess.run(["bluetoothctl"] + cmd.split(),
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            text=True)
    return result.stdout

def search_wiimote(keywords, timeout=30, interval=2):
    """
    Repeatedly searches the device list for an entry that contains one 
    of the keywords.
    """
    start_time = time.time()
    device_mac = None
    while time.time() - start_time < timeout:
        devices_out = run_bluetoothctl_command("devices")
        for line in devices_out.splitlines():
            if any(kw.lower() in line.lower() for kw in keywords):
                match = re.search(r'Device\s+([0-9A-F:]{17})', line, re.I)
                if match:
                    device_mac = match.group(1)
                    print("Found device: " + line)
                    return device_mac
        print("No matching Wiimote device found, waiting {} seconds...".format(interval))
        time.sleep(interval)
    return device_mac

def main():
    print("Please put your Wiimote in pairing mode (hold buttons 1+2)!")

    # Ensure that the Bluetooth adapter is powered on and the agent is active.
    run_bluetoothctl_command("power on")
    run_bluetoothctl_command("agent on")
    run_bluetoothctl_command("default-agent")

    # Start scanning for Bluetooth devices.
    print("Starting scan ...")
    run_bluetoothctl_command("scan on")
    # Allow a short delay to collect initial scan results.
    time.sleep(2)

    # Search for typical names that indicate a Wiimote.
    keywords = ["Nintendo", "Wiimote", "RVL-CNT-01"]
    device_mac = search_wiimote(keywords)

    # Stop the scanning process.
    run_bluetoothctl_command("scan off")

    if not device_mac:
        print("No Wiimote device found. Please check that it is in pairing mode!")
        sys.exit(1)

    print("Target device: " + device_mac)

    # Mark the device as trusted, then attempt pairing and connection.
    print("Setting device as trusted ...")
    run_bluetoothctl_command("trust " + device_mac)
    time.sleep(1)

    print("Initiating pairing ...")
    run_bluetoothctl_command("pair " + device_mac)
    time.sleep(4)

    print("Attempting to connect to the device ...")
    run_bluetoothctl_command("connect " + device_mac)
    time.sleep(4)

    # Verify that the device is connected.
    info = run_bluetoothctl_command("info " + device_mac)
    if "Connected: yes" in info:
        print("Wiimote successfully connected!")
    else:
        print("Error connecting to the device. 'info' output:")
        print(info)
        sys.exit(1)

if __name__ == '__main__':
    main()
