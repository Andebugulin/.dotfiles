#!/bin/bash
# ~/.config/waybar/scripts/toggle-clock-workspaces.sh

STATE_FILE="$HOME/.config/waybar/clock-workspace-state"

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
  echo "clock" > "$STATE_FILE"
fi

current_state=$(cat "$STATE_FILE")

if [ "$1" = "click" ]; then
  if [ "$current_state" = "clock" ]; then
    echo "workspace" > "$STATE_FILE"
  else
    echo "clock" > "$STATE_FILE"
  fi
  # Remove this line that was causing crashes
  # pkill -SIGUSR1 waybar
fi

current_state=$(cat "$STATE_FILE")

if [ "$current_state" = "clock" ]; then
  echo '{"text": "'$(date +"%H:%M")'", "class": "clock", "tooltip": "'$(date +"%A, %B %d, %Y")'"}'
else
  # Just include output of your workspace script
  ~/.config/waybar/scripts/workspace-app-icons.sh
fi