#!/bin/bash
# Script for generating music visualization with cava

# First, ensure cava is installed
if ! command -v cava &> /dev/null; then
    echo "{\"text\": \"󰋎\", \"tooltip\": \"Cava not installed\"}"
    exit 1
fi

# Check if audio is playing
if ! pactl list sinks | grep -q "RUNNING"; then
    echo "{\"text\": \"\", \"tooltip\": \"No audio playing\"}"
    exit 0
fi

# Configuration
bar_count=8
bar_height=20
bar_width=3
gap_size=2
update_interval=0.05
char_set=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Create temporary config
temp_config=$(mktemp)
cat > "$temp_config" << EOF
[general]
bars = $bar_count
framerate = 60
sensitivity = 100
autosens = 1

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = ${#char_set[@]}
bar_delimiter = ""
EOF

# Run cava with our config and format the output
output=$(cava -p "$temp_config" 2>/dev/null | head -n 1)

# Clean up
rm "$temp_config"

# If no music is playing or output is empty, show a simple icon
if [[ -z "$output" ]]; then
    echo "{\"text\": \"\", \"tooltip\": \"No audio playing\"}"
    exit 0
fi

# Format the output
formatted_output=""
for bar in $output; do
    # Convert bar value to character
    index=$((bar-1))
    if [[ $index -lt 0 ]]; then
        index=0
    fi
    if [[ $index -ge ${#char_set[@]} ]]; then
        index=$((${#char_set[@]}-1))
    fi
    
    # Add the character
    formatted_output+="${char_set[$index]}"
done

# Return JSON for waybar
echo "{\"text\": \"$formatted_output\", \"tooltip\": \"Audio Visualizer\"}"