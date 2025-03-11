#!/bin/bash
# Script for generating music visualization with cava

# Ensure we have proper output even when not connected to a terminal
export TERM=xterm

# Return a default output if cava is not installed
if ! command -v cava &> /dev/null; then
    echo "{\"text\": \"󰎆\", \"class\": \"no-cava\", \"tooltip\": \"Cava not installed\"}"
    exit 0
fi

# Create temporary config file
temp_config=$(mktemp)
cat > "$temp_config" << EOF
[general]
bars = 8
framerate = 30
autosens = 1
sensitivity = 100
overshoot = 0

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 8
EOF

# Function to output visualizer when no audio is playing
output_empty() {
    echo "{\"text\": \"▁▁▁▁▁▁▁▁\", \"class\": \"no-audio\", \"tooltip\": \"No audio playing\"}"
    exit 0
}

# Check if any audio is playing (this may vary by system)
if ! pactl list sink-inputs 2>/dev/null | grep -q "State: RUNNING"; then
    output_empty
fi

# Try to get one frame from cava
# Increase timeout to 2 seconds to give cava enough time to initialize
output=$(timeout 2s cava -p "$temp_config" 2>/dev/null | head -n 1)
rm -f "$temp_config"

# Debugging: Print the output from cava
echo "Debug: cava output: $output" >&2

# If we didn't get output or it's empty, show empty visualizer
if [ -z "$output" ]; then
    output_empty
fi

# Process the output
char_set=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
formatted=""

# Convert numbers to characters
for value in $output; do
    # Ensure value is a number and within range
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        continue
    fi
    if [ "$value" -lt 1 ]; then value=1; fi
    if [ "$value" -gt ${#char_set[@]} ]; then value=${#char_set[@]}; fi
    
    # Append the character (subtract 1 for zero-based indexing)
    formatted="${formatted}${char_set[$((value-1))]}"
done

# If we somehow got an empty formatted string, show default
if [ -z "$formatted" ]; then
    output_empty
fi

# Return JSON for waybar
echo "{\"text\": \"$formatted\", \"class\": \"playing\", \"tooltip\": \"Audio Visualizer\"}"