#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Downloads/wallpapers"  # Change this to your wallpaper directory
CURRENT_WALLPAPER_FILE="$HOME/.config/waybar/current_wallpaper.txt"
WALLPAPER_LIST="$HOME/.config/waybar/wallpaper_list.txt"
POSITION_FILE="$HOME/.config/waybar/current_position.txt"

# Create initial wallpaper list if it doesn't exist
if [ ! -f "$WALLPAPER_LIST" ]; then
    find "$WALLPAPER_DIR" -type f -name "*.jpg" -o -name "*.png" | sort > "$WALLPAPER_LIST"
fi

# Initialize position file if it doesn't exist
if [ ! -f "$POSITION_FILE" ]; then
    echo "0" > "$POSITION_FILE"
fi

# Create current wallpaper file if it doesn't exist
if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
    head -n 1 "$WALLPAPER_LIST" > "$CURRENT_WALLPAPER_FILE"
fi

# Function to shuffle the wallpaper list
shuffle_wallpapers() {
    # Make a backup of the original list first (optional)
    cp "$WALLPAPER_LIST" "${WALLPAPER_LIST}.bak"
    
    # Shuffle the list
    shuf "$WALLPAPER_LIST" > "${WALLPAPER_LIST}.tmp"
    mv "${WALLPAPER_LIST}.tmp" "$WALLPAPER_LIST"
    
    # Reset position
    echo "0" > "$POSITION_FILE"
    
    # Set current wallpaper to first in list
    head -n 1 "$WALLPAPER_LIST" > "$CURRENT_WALLPAPER_FILE"
}

update_and_show() {
    current=$(cat "$CURRENT_WALLPAPER_FILE")
    wallpaper_name=$(basename "$current")
    
    # Apply the wallpaper
    killall swaybg 2>/dev/null  # Kill any existing swaybg process
    swaybg -i "$current" -m fill &
    
    # Update the tooltip for waybar
    echo "{\"text\":\"󰸉\", \"tooltip\":\"$wallpaper_name\", \"class\":\"wallpaper-active\"}"
}

# Handle direction argument
if [ "$1" = "click" ]; then
    # On click, go to next wallpaper
    "$0" next
    
elif [ "$1" = "next" ]; then
    # Get current position
    position=$(cat "$POSITION_FILE")
    
    # Get total number of wallpapers
    total_wallpapers=$(wc -l < "$WALLPAPER_LIST")
    
    # Calculate next position
    next_position=$((position + 1))
    
    # Check if we reached the end of the list
    if [ "$next_position" -ge "$total_wallpapers" ]; then
        # Shuffle the list and start from beginning
        shuffle_wallpapers
        next_position=0
    fi
    
    # Get the next wallpaper
    next=$(sed -n "$((next_position + 1))p" "$WALLPAPER_LIST")
    
    # Update position and current wallpaper
    echo "$next_position" > "$POSITION_FILE"
    echo "$next" > "$CURRENT_WALLPAPER_FILE"
    
    update_and_show
    
elif [ "$1" = "prev" ]; then
    # Get current position
    position=$(cat "$POSITION_FILE")
    
    # Get total number of wallpapers
    total_wallpapers=$(wc -l < "$WALLPAPER_LIST")
    
    # Calculate previous position
    prev_position=$((position - 1))
    
    # Check if we're at the beginning of the list
    if [ "$prev_position" -lt 0 ]; then
        prev_position=$((total_wallpapers - 1))
    fi
    
    # Get the previous wallpaper
    prev=$(sed -n "$((prev_position + 1))p" "$WALLPAPER_LIST")
    
    # Update position and current wallpaper
    echo "$prev_position" > "$POSITION_FILE"
    echo "$prev" > "$CURRENT_WALLPAPER_FILE"
    
    update_and_show
    
else
    # Just display the icon and current wallpaper name
    current=$(cat "$CURRENT_WALLPAPER_FILE")
    wallpaper_name=$(basename "$current")
    echo "{\"text\":\"󰸉\", \"tooltip\":\"$wallpaper_name\"}"
fi