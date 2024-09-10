#!/bin/bash
# Wait for 10 seconds
sleep 10
# Logout command. This is just a placeholder, you'll need to replace it
# with the command that actually logs you out of Hyprland.
# For example, if you're using `swaymsg` for sway, you might have something similar for Hyprland.
killall -u $(whoami) -o hyprland
