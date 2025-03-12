#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Downloads/wallpapers"  # Change this to your wallpaper directory
CURRENT_WALLPAPER_FILE="$HOME/.config/waybar/current_wallpaper.txt"
WALLPAPER_LIST="$HOME/.config/waybar/wallpaper_list.txt"
HISTORY_FILE="$HOME/.config/waybar/wallpaper_history.txt"  # Track previously shown wallpapers
MAX_HISTORY=10  # Number of wallpapers to avoid repeating

# Function to update the wallpaper list with all current wallpapers
update_wallpaper_list() {
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.JPG" -o -name "*.png" -o -name "*.PNG" -o -name "*.jpeg" -o -name "*.JPEG" \) | sort > "$WALLPAPER_LIST"
    # If the list is empty, there might be a problem with the directory
    if [ ! -s "$WALLPAPER_LIST" ]; then
        echo "Warning: No wallpapers found in $WALLPAPER_DIR" >&2
        return 1
    fi
    return 0
}

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
    touch "$HISTORY_FILE"
fi

# Always update the wallpaper list to include any new images
update_wallpaper_list

# Initialize current wallpaper file if it doesn't exist
if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
    head -n 1 "$WALLPAPER_LIST" > "$CURRENT_WALLPAPER_FILE"
    echo "$(cat "$CURRENT_WALLPAPER_FILE")" >> "$HISTORY_FILE"
fi

# Function to pick a truly random wallpaper that hasn't been shown recently
pick_random_wallpaper() {
    total_wallpapers=$(wc -l < "$WALLPAPER_LIST")
    
    # If we have very few wallpapers, just use standard random selection
    if [ "$total_wallpapers" -le "$MAX_HISTORY" ]; then
        random_line=$((RANDOM % total_wallpapers + 1))
        sed -n "${random_line}p" "$WALLPAPER_LIST"
        return
    fi
    
    # Try to find a wallpaper that isn't in the recent history
    local attempts=0
    local max_attempts=20  # Avoid infinite loops
    
    while [ "$attempts" -lt "$max_attempts" ]; do
        random_line=$((RANDOM % total_wallpapers + 1))
        candidate=$(sed -n "${random_line}p" "$WALLPAPER_LIST")
        
        # Check if this wallpaper is in our recent history
        if ! grep -q "^$candidate$" "$HISTORY_FILE"; then
            echo "$candidate"
            return
        fi
        
        attempts=$((attempts + 1))
    done
    
    # If we failed to find a non-recent wallpaper after several attempts,
    # just return a random one anyway
    random_line=$((RANDOM % total_wallpapers + 1))
    sed -n "${random_line}p" "$WALLPAPER_LIST"
}

# Function to update history of recently shown wallpapers
update_history() {
    local wallpaper="$1"
    
    # Add the new wallpaper to history
    echo "$wallpaper" >> "$HISTORY_FILE"
    
    # Keep only the most recent MAX_HISTORY entries
    if [ "$(wc -l < "$HISTORY_FILE")" -gt "$MAX_HISTORY" ]; then
        tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

update_and_show() {
    current=$(cat "$CURRENT_WALLPAPER_FILE")
    
    # Check if the current wallpaper file exists
    if [ ! -f "$current" ]; then
        echo "Warning: Current wallpaper file doesn't exist: $current" >&2
        # Use a random wallpaper instead
        new_wallpaper=$(pick_random_wallpaper)
        echo "$new_wallpaper" > "$CURRENT_WALLPAPER_FILE"
        current="$new_wallpaper"
        update_history "$current"
    fi
    
    wallpaper_name=$(basename "$current")
    
    # Apply the wallpaper
    killall swaybg 2>/dev/null  # Kill any existing swaybg process
    swaybg -i "$current" -m fill &
    
    # Update the tooltip for waybar
    echo "{\"text\":\"󰸉\", \"tooltip\":\"$wallpaper_name\", \"class\":\"wallpaper-active\"}"
}

# Handle direction argument
if [ "$1" = "click" ] || [ "$1" = "next" ]; then
    # Pick a truly random wallpaper that's not in our recent history
    new_wallpaper=$(pick_random_wallpaper)
    
    # Update current wallpaper
    echo "$new_wallpaper" > "$CURRENT_WALLPAPER_FILE"
    
    # Update history
    update_history "$new_wallpaper"
    
    update_and_show
    
elif [ "$1" = "prev" ]; then
    # Get the previous wallpaper from history (second most recent)
    if [ "$(wc -l < "$HISTORY_FILE")" -gt 1 ]; then
        prev=$(tail -n 2 "$HISTORY_FILE" | head -n 1)
        echo "$prev" > "$CURRENT_WALLPAPER_FILE"
        update_and_show
    else
        # Not enough history, just pick a random one
        new_wallpaper=$(pick_random_wallpaper)
        echo "$new_wallpaper" > "$CURRENT_WALLPAPER_FILE"
        update_history "$new_wallpaper"
        update_and_show
    fi
    
elif [ "$1" = "refresh" ]; then
    # Completely refresh the wallpaper list and reset
    update_wallpaper_list
    new_wallpaper=$(pick_random_wallpaper)
    echo "$new_wallpaper" > "$CURRENT_WALLPAPER_FILE"
    
    # Clear history and add this wallpaper
    > "$HISTORY_FILE"
    update_history "$new_wallpaper"
    
    update_and_show
    
else
    # Just display the icon and current wallpaper name
    current=$(cat "$CURRENT_WALLPAPER_FILE")
    wallpaper_name=$(basename "$current")
    echo "{\"text\":\"󰸉\", \"tooltip\":\"$wallpaper_name\"}"
fi