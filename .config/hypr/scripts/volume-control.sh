#!/bin/bash
# Save as ~/.config/hypr/scripts/volume-control.sh

# Set maximum volume percent (e.g. 150%)
MAX_VOL=150

case $1 in
    up)
        # Get current volume
        CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1)
        
        # Only increase if below max
        if [ "$CURRENT_VOL" -lt "$MAX_VOL" ]; then
            pactl set-sink-volume @DEFAULT_SINK@ +5%
        fi
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    toggle)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 {up|down|toggle}"
        exit 1
        ;;
esac