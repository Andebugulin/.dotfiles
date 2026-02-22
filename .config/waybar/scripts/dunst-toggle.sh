#!/bin/bash

# Script to toggle and display Dunst notification status

if [ "$1" = "click" ]; then
    # Toggle dunst notifications
    dunstctl set-paused toggle
fi

# Check if dunst is paused
if dunstctl is-paused | grep -q "true"; then
    # Notifications are paused (DND mode)
    echo '{"text":"󰂛","class":"dnd-on","tooltip":"Do Not Disturb: ON\nClick to enable notifications"}'
else
    # Notifications are active
    echo '{"text":"󰂚","class":"dnd-off","tooltip":"Notifications: ON\nClick for Do Not Disturb"}'
fi