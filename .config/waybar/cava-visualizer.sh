#!/bin/bash
# Script for generating music visualization with cava

# First, ensure cava is installed
if ! command -v cava &> /dev/null; then
    echo "󰋎"; # Display music icon if cava not found
    exit 1
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
cava -p "$temp_config" | while read -r line; do
    output=""
    for bar in $line; do
        # Convert bar value to character
        index=$((bar-1))
        if [[ $index -lt 0 ]]; then
            index=0
        fi
        if [[ $index -ge ${#char_set[@]} ]]; then
            index=$((${#char_set[@]}-1))
        fi
        
        # Add color based on height
        if [[ $index -lt 2 ]]; then
            color="#89b4fa" # Blue for low
        elif [[ $index -lt 4 ]]; then
            color="#a6e3a1" # Green for medium
        elif [[ $index -lt 6 ]]; then
            color="#f9e2af" # Yellow for high
        else
            color="#f38ba8" # Red for very high
        fi
        
        # Add the character with color
        output+="<span color='$color'>${char_set[$index]}</span>"
    done
    
    # If no music is playing, show a simple icon
    if [[ $(echo "$output" | tr -d '[:space:]<>spancolor=') == "" ]]; then
        echo "󰎆"
    else
        # Add some styling
        echo "<span font='monospace'>$output</span>"
    fi
    
    sleep "$update_interval"
done

# Clean up
rm "$temp_config"