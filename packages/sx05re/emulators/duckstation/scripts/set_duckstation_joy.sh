#!/bin/bash
# duckstationjoy.sh - Convert SDL GameControllerDB mappings to DuckStation INI format
# Usage: duckstationjoy.sh [OPTIONS] guid1 [guid2] [guid3] [guid4]

OUTPUT_FILE="/emuelec/configs/duckstation/settings.ini"
LAST_GUIDE_BUTTON=""

# SDL_GameControllerButton enum values
declare -A SDL_BUTTON_ENUM=(
    [a]=0 [b]=1 [x]=2 [y]=3
    [back]=4 [select]=4 [guide]=5 [hotkeyenable]=5 [start]=6
    [leftstick]=7 [leftthumb]=7
    [rightstick]=8 [rightthumb]=8
    [leftshoulder]=9 [rightshoulder]=10
    [dpup]=11 [dpdown]=12 [dpleft]=13 [dpright]=14
)

# DuckStation button names - Xbox/Standard layout
declare -A DUCKSTATION_BUTTONS=(
    [a]="ButtonCross" [b]="ButtonCircle" [x]="ButtonSquare" [y]="ButtonTriangle"
    [dpup]="ButtonUp" [dpdown]="ButtonDown" [dpleft]="ButtonLeft" [dpright]="ButtonRight"
    [leftshoulder]="ButtonL1" [rightshoulder]="ButtonR1"
    [leftstick]="ButtonL3" [leftthumb]="ButtonL3"
    [rightstick]="ButtonR3" [rightthumb]="ButtonR3"
    [start]="ButtonStart" [back]="ButtonSelect" [select]="ButtonSelect"
)

# DuckStation button names - Nintendo layout (A/B and X/Y swapped)
declare -A NINTENDO_LAYOUT_BUTTONS=(
    [a]="ButtonCircle" [b]="ButtonCross" [x]="ButtonTriangle" [y]="ButtonSquare"
    [dpup]="ButtonUp" [dpdown]="ButtonDown" [dpleft]="ButtonLeft" [dpright]="ButtonRight"
    [leftshoulder]="ButtonL1" [rightshoulder]="ButtonR1"
    [leftstick]="ButtonL3" [leftthumb]="ButtonL3"
    [rightstick]="ButtonR3" [rightthumb]="ButtonR3"
    [start]="ButtonStart" [back]="ButtonSelect" [select]="ButtonSelect"
)

# DuckStation axis names
declare -A DUCKSTATION_AXES=(
    [leftx]="AxisLeftX" [lefty]="AxisLeftY"
    [rightx]="AxisRightX" [righty]="AxisRightY"
)

# Generate DuckStation config for one controller
generate_config() {
    local controller_num="$1"
    local mapping="$2"
    LAST_GUIDE_BUTTON=""
    
    [ -z "$mapping" ] && return 1
    
    # Parse mapping: guid,name,key:value,key:value,...
    IFS=',' read -ra PARTS <<< "$mapping"
    local controller_name="${PARTS[1]}"
    
    # Choose button mapping based on controller type
    local -n BUTTON_MAP
        BUTTON_MAP=NINTENDO_LAYOUT_BUTTONS
#        BUTTON_MAP=DUCKSTATION_BUTTONS
    
    echo "[Controller$((controller_num + 1))]"
    echo "Type = AnalogController"
    echo "AnalogDPadInDigitalMode = true"
    
    local guide_button=""
    
    # Process each mapping element (skip first 2: guid and name)
    for ((i=2; i<${#PARTS[@]}; i++)); do
        local part="${PARTS[i]}"
        
        # Skip metadata
        [[ "$part" =~ ^(platform|crc|sdk): ]] && continue
        
        IFS=':' read -r key value <<< "$part"
        
        # Handle buttons
        if [[ "$value" =~ ^b([0-9]+)$ ]]; then
            # Triggers mapped as buttons -> convert to axes
            if [ "$key" = "lefttrigger" ]; then
                echo "ButtonL2 = Controller${controller_num}/+Axis4"
            elif [ "$key" = "righttrigger" ]; then
                echo "ButtonR2 = Controller${controller_num}/+Axis5"
            else
                local enum_value="${SDL_BUTTON_ENUM[$key]}"
                local duck_name="${BUTTON_MAP[$key]}"
                
                if [ -n "$enum_value" ] && [ -n "$duck_name" ]; then
                    echo "$duck_name = Controller${controller_num}/Button${enum_value}"
                fi
                
                # Track guide/back button for hotkeys (prefer back)
                if [ "$key" = "back" ] || [ "$key" = "select" ]; then
                    guide_button="$enum_value"
                    LAST_GUIDE_BUTTON="$enum_value"
                elif [ "$key" = "guide" ] && [ -z "$guide_button" ]; then
                    guide_button="$enum_value"
                    LAST_GUIDE_BUTTON="$enum_value"
                fi
            fi
        
        # Handle axes
        elif [[ "$value" =~ ^a([0-9]+)$ ]]; then
            local axis_num="${BASH_REMATCH[1]}"
            
            if [ "$key" = "lefttrigger" ]; then
                echo "ButtonL2 = Controller${controller_num}/+Axis${axis_num}"
            elif [ "$key" = "righttrigger" ]; then
                echo "ButtonR2 = Controller${controller_num}/+Axis${axis_num}"
            else
                local duck_name="${DUCKSTATION_AXES[$key]}"
                [ -n "$duck_name" ] && echo "$duck_name = Controller${controller_num}/Axis${axis_num}"
            fi
        
        # Handle hats (D-pad)
        elif [[ "$value" =~ ^h([0-9]+)\.([0-9]+)$ ]]; then
            local enum_value="${SDL_BUTTON_ENUM[$key]}"
            local duck_name="${BUTTON_MAP[$key]}"
            
            if [ -n "$enum_value" ] && [ -n "$duck_name" ]; then
                echo "$duck_name = Controller${controller_num}/Button${enum_value}"
            fi
        fi
    done
}

# Merge controller configs into existing settings.ini
merge_controller_configs() {
    local settings_file="$1"
    shift
    
    # Extract guide buttons (before the -- separator)
    local guide_buttons=()
    while [ "$1" != "--" ]; do
        guide_buttons+=("$1")
        shift
    done
    shift
    
    local temp_configs=("$@")
    local temp_output=$(mktemp)
    local current_section=""
    local skip_section=false
    
    # Build list of controller sections we're replacing
    local controller_sections=()
    for i in "${!temp_configs[@]}"; do
        controller_sections+=("[Controller$((i + 1))]")
    done
    
    # Read existing settings.ini, skip controller and hotkey sections we're replacing
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            current_section="$line"
            skip_section=false
            
            # Skip controller sections we're replacing
            for section in "${controller_sections[@]}"; do
                [ "$current_section" = "$section" ] && skip_section=true && break
            done
            
            # Skip old [Hotkeys] section
            [ "$current_section" = "[Hotkeys]" ] && skip_section=true
            
            [ "$skip_section" = false ] && echo "$line" >> "$temp_output"
        elif [ "$skip_section" = false ]; then
            echo "$line" >> "$temp_output"
        fi
    done < "$settings_file"
    
    # Append new controller configurations
    for temp_file in "${temp_configs[@]}"; do
        echo "" >> "$temp_output"
        cat "$temp_file" >> "$temp_output"
    done
    
    # Add single [Hotkeys] section
    echo "" >> "$temp_output"
    echo "[Hotkeys]" >> "$temp_output"
    [ -n "${guide_buttons[0]}" ] && echo "OpenQuickMenu = Controller0/Button${guide_buttons[0]}" >> "$temp_output"
    
    mv "$temp_output" "$settings_file"
}

# Main script
main() {
    local guids=()
    
	# Capture GUIDs into a variable
	detected_guids=$(gamepad_info 2>/dev/null | grep -oP '^[0-9a-f]{32}' | head -n4)

	# Use mapfile to convert the result into an array
	mapfile -t guids <<< "$detected_guids"
   
    # Find settings file
    local settings_file=""
	settings_file="$OUTPUT_FILE"
    
    # Generate controller configs
    local temp_configs=()
    local guide_buttons=()
    
    for i in "${!guids[@]}"; do
        local guid="${guids[$i]}"
        local mapping=$(gamepad_info 2>/dev/null | grep "^$guid" | head -n1)
        
        if [ -z "$mapping" ]; then
            echo "Warning: No mapping found for GUID: $guid" >&2
            continue
        fi
        
        local temp_file=$(mktemp)
        generate_config "$i" "$mapping" > "$temp_file"
        temp_configs+=("$temp_file")
        guide_buttons+=("$LAST_GUIDE_BUTTON")
    done
    
    [ ${#temp_configs[@]} -eq 0 ] && echo "Error: No valid configurations generated" >&2 && exit 1
    merge_controller_configs "$settings_file" "${guide_buttons[@]}" -- "${temp_configs[@]}"
    
    # Cleanup
    rm -f "${temp_configs[@]}"
}

main "$@"
