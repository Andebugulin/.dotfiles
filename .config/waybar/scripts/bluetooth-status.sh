#!/bin/bash
# Script to check bluetooth connection status and show connected device

# Check if bluetooth is powered on
if bluetoothctl show | grep -q "Powered: yes"; then
    # Check for connected devices
    if bluetoothctl devices Connected | grep -q "Device"; then
        # Get the name of the connected device
        device_name=$(bluetoothctl devices Connected | head -n 1 | cut -d ' ' -f 3-)
        # Check if it's likely headphones/audio device
        if echo "$device_name" | grep -iq -e "headphone" -e "buds" -e "airpods" -e "earphone" -e "audio"; then
            # It's headphones
            echo "{\"text\": \"󰋋 $device_name\", \"class\": \"connected\", \"tooltip\": \"Connected to $device_name\"}"
        else
            # Other bluetooth device
            echo "{\"text\": \"󰂱 $device_name\", \"class\": \"connected\", \"tooltip\": \"Connected to $device_name\"}"
        fi
    else
        # Bluetooth on but not connected
        echo "{\"text\": \"󰂯\", \"class\": \"disconnected\", \"tooltip\": \"Bluetooth On\"}"
    fi
else
    # Bluetooth powered off
    echo "{\"text\": \"󰂲\", \"class\": \"off\", \"tooltip\": \"Bluetooth Off\"}"
fi