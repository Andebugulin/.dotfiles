#!/bin/bash
killall waybar
SDIR="$HOME/.config/waybar"
waybar -c "$SDIR"/mocha.jsonc -s "$SDIR"/mocha.css &
killall swaybg
# Directory containing your wallpapers
WALLPAPERS_DIR=~/Downloads/wallpapers

# Select a random wallpaper
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f | shuf -n 1)

# Set the wallpaper with swaybg
swaybg -i "$WALLPAPER" -m fill &
