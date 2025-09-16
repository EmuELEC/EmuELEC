#!/bin/bash

ES_SYSTEMS="/storage/.config/emulationstation/es_systems.cfg"

# Extract path elements from XML and filter out those not containing "/storage/roms"
PATHS=$(grep -oP '(?<=<path>).*?(?=</path>)' "${ES_SYSTEMS}" | grep '/storage/roms')

# Loop through each path and create directories
while IFS= read -r path; do
    #echo "${path}"
    mkdir -p "${path}"
    chmod +x 0777 "${path}"
done <<< "${PATHS}"

